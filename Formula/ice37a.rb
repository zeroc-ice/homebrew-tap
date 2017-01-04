class Ice37a < Formula
  desc "A comprehensive RPC framework with support for C++, .NET, Java, Python, JavaScript and more"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice.git", :branch => "master"
  version "3.7a4"

  option "with-additional-compilers", "Build additional Slice compilers (slice2py, slice2js, slice2rb)"
  option "with-java", "Build Ice for Java and the IceGrid Admin app"
  option "with-xcode-sdk", "Build Xcode SDK for iOS development (includes static libs)"

  depends_on "lmdb"
  depends_on "mcpp"
  depends_on :java => [ "1.8+", :optional]
  depends_on :macos => :mavericks

  def install

    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    # Ensure Gradle uses a writable directory even in sandbox mode
    ENV["GRADLE_USER_HOME"] = buildpath/".gradle"

    args = [
      "prefix=#{prefix}",
      "embedded_runpath_prefix=#{prefix}",
      "OPTIMIZE=yes",
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "CONFIGS=shared cpp11-shared #{(build.with? 'xcode-sdk') ? 'xcodesdk cpp11-xcodesdk' : ''}",
      "PLATFORMS=all",
      "SKIP=#{(build.without? 'additional-compilers') ? 'slice2py slice2rb slice2js' : ''}",
      "LANGUAGES=cpp objective-c #{(build.with? 'java') ? 'java java-compat' : ''}"
    ]
    system "make", "install", *args
  end

  def caveats; <<-EOS.undent
    Ice is built using the latest commit on the master branch on GitHub (https://github.com/zeroc-ice/ice/master).
    To update to the latest commit you need to reinstall this package.
    EOS
  end

  test do
    (testpath/"Hello.ice").write <<-EOS.undent
      module Test {
        interface Hello {
          void sayHello();
        };
      };
    EOS
    (testpath/"Test.cpp").write <<-EOS.undent
      #include <Ice/Ice.h>
      #include <Hello.h>

      class HelloI : public Test::Hello {
      public:
        virtual void sayHello(const Ice::Current&) {}
      };

      int main(int argc, char* argv[]) {
        Ice::CommunicatorPtr communicator;
        communicator = Ice::initialize(argc, argv);
        Ice::ObjectAdapterPtr adapter =
            communicator->createObjectAdapterWithEndpoints("Hello", "default -h localhost -p 10000");
        adapter->add(new HelloI, communicator->stringToIdentity("hello"));
        adapter->activate();
        communicator->destroy();
        return 0;
      }
    EOS
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "clang++", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system "xcrun", "clang++", "-c", "-I#{include}", "-I.", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce", "-lIceUtil"
    system "./test", "--Ice.InitPlugins=0"
  end
end
