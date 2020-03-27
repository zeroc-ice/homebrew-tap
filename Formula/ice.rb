class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.3.tar.gz"
  sha256 "7cbfac83684a7434499f165e784a7a7bb5b89140717537067d7b969eccc111eb"
  revision 1

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "cb257ae6deb585e358ea2c995e7cd2848a4053c30e2075645601df76a03f7124" => :catalina
  end

  option "with-java", "Build the Ice for Java jar files"
  option "without-xcode-sdk", "Build without the Xcode SDK for iOS development"

  depends_on "lmdb"
  depends_on "mcpp"
  depends_on :java => ["1.8+", :optional]

  patch do
    url "https://github.com/zeroc-ice/ice/commit/c6306e50ce3e5d48c3a0b0e3aab4129c3f430eeb.patch?full_index=1"
    sha256 "09178ee9792587411df6592a4c2a6d01ea7b706cf68d0d5501c0e91d398e0c38"
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
      "SKIP=slice2confluence",
      "LANGUAGES=cpp objective-c #{build.with?("java") ? "java java-compat" : ""}",
    ]
    system "make", "install", *args

    (libexec/"bin").mkpath
    %w[slice2py slice2rb slice2js].each do |r|
      mv bin/r, libexec/"bin"
    end
  end

  def caveats
    <<~EOS
      slice2py, slice2js and slice2rb were installed in:

        #{opt_libexec}/bin

      You may wish to add this directory to your PATH.
    EOS
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
      system "xcrun", "--sdk", "macosx", "clang++", "-L#{lib}/IceSDK/macosx.sdk/usr/lib", "-o", "test-sdk", \
        "Test.o", "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", "-lbz2", "-liconv"
      system "./test-sdk"
    end
  end
end
