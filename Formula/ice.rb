class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0.tar.gz"
  sha256 "809fff14a88a7de1364c846cec771d0d12c72572914e6cc4fb0b2c1861c4a1ee"
  revision 1

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "4116fa6522b9c3f66c37df6ced5c1c11415b6fd5e28600c837535373a8708eb3" => :high_sierra
    sha256 "0d165faabb2f06045c4ab97711c5fe1b82a30bdc1bf93e913e8277a5bc00ada5" => :sierra
  end

  # Xcode 9 support
  patch do
    url "https://github.com/zeroc-ice/ice/commit/3a55ebb51b8914b60d308a0535d9abf97567138d.patch?full_index=1"
    sha256 "d95e76acebdae69edf3622f5141ea32bbbd5844be7c29d88e6e985d14a5d5dd4"
  end

  #
  # NOTE: we don't build slice2py, slice2js, slice2rb by default to prevent clashes with
  # the translators installed by the PyPI/GEM/npm packages.
  #

  option "with-additional-compilers", "Build additional Slice compilers (slice2py, slice2js, slice2rb)"
  option "with-java", "Build Ice for Java and the IceGrid GUI app"
  option "without-xcode-sdk", "Build without the Xcode SDK for iOS development (includes static libs)"

  depends_on "mcpp"
  depends_on "lmdb"
  depends_on :java => ["1.8+", :optional]
  depends_on :macos => :mavericks

  def install
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
    (testpath / "Hello.ice").write <<-EOS.undent
      module Test
      {
          interface Hello
          {
              void sayHello();
          }
      }
    EOS
    (testpath / "Test.cpp").write <<-EOS.undent
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
        auto adapter = ich->createObjectAdapterWithEndpoints("Hello", "default -h localhost -p 10000");
        adapter->add(std::make_shared<HelloI>(), Ice::stringToIdentity("hello"));
        adapter->activate();
        return 0;
      }
    EOS
    system "#{bin}/slice2cpp", "Hello.ice"
    system ENV.cxx, "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system ENV.cxx, "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Test.cpp"
    system ENV.cxx, "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce++11"
    system "./test"
    if File.directory?("#{opt_prefix}/sdk")
      system "xcrun", "--sdk", "macosx", ENV.cxx, "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
        "-I#{opt_prefix}/sdk/macosx.sdk/usr/include", "-I.", "Hello.cpp"
      system "xcrun", "--sdk", "macosx", ENV.cxx, "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
        "-I#{opt_prefix}/sdk/macosx.sdk/usr/include", "-I.", "Test.cpp"
      system "xcrun", "--sdk", "macosx", ENV.cxx, "-L#{opt_prefix}/sdk/macosx.sdk/usr/lib", "-o", "test-sdk", "Test.o", \
        "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", "-lbz2", "-liconv"
      system "./test-sdk"
    end
  end
end
