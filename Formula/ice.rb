class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.10.tar.gz"
  sha256 "b90e9015ca9124a9eadfdfc49c5fba24d3550c547f166f3c9b2b5914c00fb1df"

  bottle do
    root_url "https://download.zeroc.com/homebrew/bottles"
    sha256 cellar: :any, arm64_sonoma: "ad4108e999e023d4001a433e8595902c13d3ad19140d514a5340a78f4dd772a0"
    sha256 cellar: :any, sonoma: "e2b3e920ad794d1b8e82324fbb8a01c3e1cb2e5f52a0efb9af2d2d7e62a7f88e"
  end

  depends_on "lmdb"
  depends_on "mcpp"

  def install
    args = [
      "prefix=#{prefix}",
      "V=1",
      "USR_DIR_INSTALL=yes", # ensure slice and man files are installed to share
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "CONFIGS=all",
      "PLATFORMS=all",
      "SKIP=slice2confluence",
      "LANGUAGES=cpp objective-c",
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

    # Homebrew sets several env variables related to C++ compilation.
    # Some of these (specifically CPATH) break compilation against the iOS SDK.
    ENV.delete("CPATH")
    ENV.delete("CXXFLAGS")
    ENV.delete("CPPFLAGS")
    ENV.delete("CFLAGS")
    ENV.delete("LDFLAGS")
    ENV.delete("SDKROOT")

    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", "-I#{include}", "-I.", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce++11", "-lpthread"
    system "./test"
    # Test the iOS SDK
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Hello.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Test.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-L#{prefix}/sdk/macosx.sdk/usr/lib", "-o", "test-sdk", \
            "Test.o", "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", \
            "-lbz2", "-liconv"
    system "./test-sdk"
  end
end
