class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.8.tar.gz"
  sha256 "f2ab6b151ab0418fab30bafc2524d9ba4c767a1014f102df88d735fc775f9824"

  bottle do
    root_url "https://download.zeroc.com/homebrew/bottles"
    sha256 cellar: :any, arm64_monterey: "0c4940d22da94dfaacfad085285f733551d6a3aa3b0a84132f545cfc54ff6e44"
    sha256 cellar: :any, monterey: "8bc0126a4deee6cb67fb1b17f2e859dcca3542da735ef1f29f3c5908a284b306"
  end

  option "with-java", "Build the Ice for Java jar files"
  option "without-xcode-sdk", "Build without the Xcode SDK for iOS development"

  depends_on "lmdb"
  depends_on macos: :catalina
  depends_on "mcpp"
  depends_on "openjdk@11" => :optional

  def install
    # Ensure Gradle uses a writable directory even in sandbox mode
    ENV["GRADLE_USER_HOME"] = "#{buildpath}/.gradle"

    args = [
      "prefix=#{prefix}",
      "V=1",
      "USR_DIR_INSTALL=yes",
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
