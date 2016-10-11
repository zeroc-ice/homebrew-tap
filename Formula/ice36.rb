class Ice36 < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.6.3.tar.gz"
  sha256 "82ff74e6d24d9fa396dbb4d9697dc183b17bc9c3f6f076fecdc05632be80a2dc"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "07b6b684726a2db9fc237e67d106a649dd7bd7b047d9dec67a87d0b99bd6e31e" => :el_capitan
    sha256 "728e9058b86c16a7131f77d7808c2f740485bfb7b7adb24210bfdb60502f260c" => :sierra
  end

  option "with-java", "Build Ice for Java and the IceGrid Admin app"

  depends_on "berkeley-db53"
  depends_on "mcpp"
  depends_on :java => ["1.7+", :optional]
  depends_on :macos => :mavericks

  def install
    inreplace "cpp/src/slice2js/Makefile", /install:/, "dontinstall:"

    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    args = %W[
      prefix=#{prefix}
      USR_DIR_INSTALL=yes
      SLICE_DIR_SYMLINK=yes
      OPTIMIZE=yes
      DB_HOME=#{Formula["berkeley-db53"].opt_prefix}
      MCPP_HOME=#{Formula["mcpp"].opt_prefix}
    ]

    cd "cpp" do
      system "make", "install", *args
    end

    cd "objective-c" do
      system "make", "install", *args
    end

    if build.with? "java"
      cd "java" do
        system "make", "install", *args
      end
    end

    cd "php" do
      args << "install_phpdir=#{share}/php"
      args << "install_libdir=#{lib}/php/extensions"
      system "make", "install", *args
    end
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
