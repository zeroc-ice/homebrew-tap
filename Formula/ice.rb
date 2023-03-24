class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.9.tar.gz"
  sha256 "960b51bb14a0c89d60c0e65cb1d4c6b09fe94d4e4c033c50254f7cc9c862d3c0"

  bottle do
    root_url "https://download.zeroc.com/homebrew/bottles"
    sha256 cellar: :any, arm64_ventura: "9c156c8f9830ac43a00bd99af77497ec923ed734c4a7b84cc1a6916c212e1540"
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
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", "-I#{include}", "-I.", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce++11"
    system "./test"
    # Test the iOS SDK
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Hello.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++11", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Test.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-L#{prefix}/sdk/macosx.sdk/usr/lib", "-o", "test-sdk", \
            "Test.o", "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", \
            "-lbz2", "-liconv"
    system "./test-sdk"
  end
end
