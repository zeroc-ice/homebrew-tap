class Datastorm < Formula
  desc "Data centric pub/sub framework based on Ice"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/datastorm/archive/v1.1.0.tar.gz"
  sha256 "66d167749c49dfcc5dcb1d8a3fa34e826db313e69b792d19ae7a3f1a29b415df"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 cellar: :any, arm64_monterey: "57961c25d4d3f74233d697e75e72114f8c05cb10745a6f0eb2dc8723c38e35e4"
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
