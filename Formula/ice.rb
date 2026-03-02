class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.8.1.tar.gz"
  sha256 "87aa0381f2347715467686547bccf253fa208948bf2a462584872d2d0f8b1720"

  bottle do
    root_url "https://download.zeroc.com/ice/3.8"
    sha256 cellar: :any, arm64_tahoe: "c8ca096b86cc3658b57da43658d0c1aae4406ac713b421d7fa6dc4aff1891cb5"
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
      "LANGUAGES=cpp",
    ]
    system "make", "install", *args

    (libexec/"bin").mkpath
    mv bin/"slice2py", libexec/"bin"
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

    port = free_port

    (testpath / "Test.cpp").write <<~CPP
      #include "Hello.h"
      #include <Ice/Ice.h>

      class HelloI : public Test::Hello
      {
      public:
          void sayHello(const Ice::Current&) override {}
      };

      int main(int argc, char* argv[])
      {
        Ice::CommunicatorHolder ich(argc, argv);
        auto adapter = ich->createObjectAdapterWithEndpoints("Hello", "default -h 127.0.0.1 -p #{port}");
        adapter->add(std::make_shared<HelloI>(), Ice::stringToIdentity("hello"));
        adapter->activate();
        return 0;
      }
    CPP

    system "#{bin}/slice2cpp", "Hello.ice"
    system ENV.cxx, "clang++", "-std=c++20", "-c", "-I#{include}", "Hello.cpp"
    system ENV.cxx, "clang++", "-std=c++20", "-c", "-I#{include}", "Test.cpp"
    system ENV.cxx, "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce", "-lpthread"
    system "./test"
  end
end
