class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.1.tar.gz"
  sha256 "b1526ab9ba80a3d5f314dacf22674dff005efb9866774903d0efca5a0fab326d"
  revision 1

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "b41b082fb6f86b55590417546e28a1fe5960d1245679a6ff875aae842ac5adf5" => :mojave
    # sha256 "8e57c23280c7e77ba92b5b91a78fab78b1e0f98058ec0e2890ae2cbe174291d7" => :high_sierra
    # sha256 "ee7dfb88da13e2cc8e92d3a44e70dfa205a0ae5650cdb65c055c88ca3b4e7a50" => :sierra
  end

  #
  # NOTE: we don't build slice2py, slice2js, slice2rb by default to prevent clashes with
  # the translators installed by the PyPI/GEM/npm packages.
  #

  option "with-additional-compilers", "Build additional Slice compilers (slice2py, slice2js, slice2rb)"
  option "with-java", "Build Ice for Java and the IceGrid GUI app"
  option "without-xcode-sdk", "Build without the Xcode SDK for iOS development (includes static libs)"

  depends_on "lmdb"
  depends_on :macos => :mavericks
  depends_on "mcpp"
  depends_on :java => ["1.8+", :optional]

  patch do
    url "https://github.com/zeroc-ice/ice/compare/v3.7.1..v3.7.1-xcode10.patch?full_index=1"
    sha256 "28eff5dd6cb6065716a7664f3973213a2e5186ddbdccb1c1c1d832be25490f1b"
  end

  def install
    ENV.O2 # Os causes performance issues

    # Ensure Gradle uses a writable directory even in sandbox mode
    ENV["GRADLE_USER_HOME"] = "#{buildpath}/.gradle"

    args = [
      "prefix=#{prefix}",
      "V=1",
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "CONFIGS=shared cpp11-shared #{build.with?("xcode-sdk") ? "xcodesdk cpp11-xcodesdk" : ""}",
      "PLATFORMS=all",
      "SKIP=slice2confluence #{build.without?("additional-compilers") ? "slice2py slice2rb slice2js" : ""}",
      "LANGUAGES=cpp objective-c #{build.with?("java") ? "java java-compat" : ""}",
    ]
    system "make", "install", *args
  end

  test do
    (testpath / "Hello.ice").write <<~EOS
      module Test
      {
          interface Hello
          {
              void sayHello();
          }
      }
    EOS
    (testpath / "Test.cpp").write <<~EOS
      #include <Ice/Ice.h>
      #include <Hello.h>

      class HelloI : public Test::Hello
      {
      public:
        virtual void sayHello(const Ice::Current&) override {}
      };

      int main(int argc, char* argv[])
      {
        Ice::CommunicatorHolder ich(argc, argv);
        auto adapter = ich->createObjectAdapterWithEndpoints("Hello", "default -h localhost");
        adapter->add(std::make_shared<HelloI>(), Ice::stringToIdentity("hello"));
        adapter->activate();
        return 0;
      }
    EOS
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce++11"
    system "./test"
    if File.file?("#{lib}/IceSDK/bin/slice2cpp")
      system "#{lib}/IceSDK/bin/slice2cpp", "Hello.ice"
      system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
        "-I#{lib}/IceSDK/macosx.sdk/usr/include", "-I.", "Hello.cpp"
      system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
        "-I#{lib}/IceSDK/macosx.sdk/usr/include", "-I.", "Test.cpp"
      system "xcrun", "--sdk", "macosx", "clang++", "-L#{lib}/IceSDK/macosx.sdk/usr/lib", "-o", "test-sdk", "Test.o", \
        "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", "-lbz2", "-liconv"
      system "./test-sdk"
    end
  end
end
