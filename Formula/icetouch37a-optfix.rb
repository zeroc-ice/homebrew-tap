class Icetouch37aOptfix < Formula
  desc "Implementation of Ice for iOS and OS X targeting Xcode development"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/icetouch.git", :revision => "6103f99b16b83a820c654fff228a633f30c25292"
  version "3.7.0.alpha-optfix"

  depends_on "mcpp"

  bottle do
    cellar :any
    sha256 "69ae21020814140f9cfc12e61a022c8977371b721149fa7a04968c02d4f41cad" => :el_capitan
  end

  def install
    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.O2

    system "make", "install", "OPTIMIZE=yes", "MCPP_HOME=#{Formula["mcpp"].opt_prefix}/lib", "prefix=#{prefix}"
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
    system "#{lib}/IceTouch/Cpp/bin/slice2cpp", "hello.ice"
    system "xcrun", "--sdk", "macosx", "clang++", "-c", "-I#{lib}/IceTouch/Cpp/macosx.sdk/usr/include", "-I.", "Hello.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-c", "-I#{lib}/IceTouch/Cpp/macosx.sdk/usr/include", "-I.", "Test.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-L#{lib}/IceTouch/Cpp/macosx.sdk/usr/lib", "-o", "test", "Test.o", \
      "Hello.o", "-lIce", "-framework", "Security", "-framework", "Foundation", "-lbz2", "-liconv"
    system "./test", "--Ice.InitPlugins=0"
  end
end
