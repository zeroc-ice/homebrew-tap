class Datastorm < Formula
  desc "Data centric pub/sub framework based on Ice"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/datastorm/archive/v1.0.0.tar.gz"
  sha256 "4aa8be6dcc567d3bd87ac0b1cab459e37d4614cda2e0ac95271a902a4b6f23ba"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 big_sur: "5787ae0e9290c5e972c0335c87f5a68f1ab9ef36fd3ba2d15cbd91a26f15a93f"
  end

  depends_on "ice"

  def install
    args = [
      "prefix=#{prefix}",
      "V=1",
      "USR_DIR_INSTALL=yes",
      "ICE_BIN_DIST=all",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "LANGUAGES=cpp",
    ]

    system "make", "install", *args
  end

  # NOTE: the -L#{Formula["ice"].lib} is necessary for Mojave where the linker apparently
  # doesn't search /usr/local/lib when SDKROOT is set.
  test do
    (testpath / "Test.cpp").write <<~EOS
      #include <DataStorm/DataStorm.h>

      int main(int argc, char* argv[])
      {
        DataStorm::Node node(argc, argv);
        DataStorm::Topic<std::string, std::string> topic(node, "hello");
        DataStorm::makeSingleKeyWriter(topic, "foo");
        DataStorm::makeSingleKeyReader(topic, "foo");
        return 0;
      }
    EOS
    system "xcrun", "clang++", "-std=c++11", "-c", "-I#{include}", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-L#{Formula["ice"].lib}", "-o", "test", "Test.o", "-lDataStorm",
      "-lIce++11"
    system "./test"
  end
end
