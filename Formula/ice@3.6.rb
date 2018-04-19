class IceAT36 < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.6.4.tar.gz"
  sha256 "4f5cc5e09586eab7de7745bbdc5fbf383c59f8fdc561264d4010bba19afdde2a"
  revision 1

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "26b37f8bd5b93a5017f32d285efce1834c93fec9de51edbf2b7b31e7296fbd16" => :high_sierra
    sha256 "00121dac9f6ae65dea3038d679d347a3e8fa00174f21cd68a4ed3c6100b09144" => :sierra
  end

  # Xcode 9 support
  patch do
    url "https://github.com/zeroc-ice/ice/commit/62b1f9d4d8483e8637eb18a53922e889fa969e0a.patch?full_index=1"
    sha256 "178754a2753a06b8000759c2b7705b4a58df36b9d62f018eb291cf94a656f0d7"
  end

  option "with-java", "Build Ice for Java and the IceGrid Admin app"

  depends_on "berkeley-db@5.3"
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

    # Ensure Gradle uses a writable directory even in sandbox mode
    ENV["GRADLE_USER_HOME"] = buildpath/".gradle"

    args = %W[
      prefix=#{prefix}
      embedded_runpath_prefix=#{prefix}
      USR_DIR_INSTALL=yes
      SLICE_DIR_SYMLINK=yes
      OPTIMIZE=yes
      DB_HOME=#{Formula["berkeley-db@5.3"].opt_prefix}
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
    (testpath/"Hello.ice").write <<~EOS
      module Test {
        interface Hello {
          void sayHello();
        };
      };
    EOS
    (testpath/"Test.cpp").write <<~EOS
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
            communicator->createObjectAdapterWithEndpoints("Hello", "default -h localhost");
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
    system "/usr/bin/php", "-d", "extension_dir=#{lib}/php/extensions",
                           "-d", "extension=IcePHP.dy",
                           "-r", "extension_loaded('ice') ? exit(0) : exit(1);"
  end
end
