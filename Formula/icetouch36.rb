class Icetouch36 < Formula
  desc "Implementation of Ice for iOS and OS X targeting Xcode development"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/icetouch.git", :tag => "v3.6.3"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "a0425ee66f358a3b1b17546ccc483f49eecce815fc7ec9c27657cbc65c595826" => :el_capitan
    sha256 "4caa668241d0398e34c08db89c4321a852f0ebacabecbf215aacddcec1afad99" => :sierra
  end

  depends_on "mcpp"

  def pour_bottle?
    MacOS.xcode_version >= "7.0"
  end

  def install
    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    args = %W[
      prefix=#{prefix}
      OPTIMIZE=yes
      MCPP_HOME=#{Formula["mcpp"].opt_prefix}
    ]

    system "make", "install", *args
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
