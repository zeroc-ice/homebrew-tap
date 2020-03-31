class Datastorm < Formula
  desc "Data centric pub/sub framework based on Ice"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/datastorm/archive/v0.2.0.tar.gz"
  sha256 "ae3e4e80b1a00c4fac7f8f2b23a16e485422601117fc71790bbe851a2db7b190"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "aa25970c4903cea68548559018907ac41993e5aff1f728492bec9e751c0ba222" => :catalina
  end

  depends_on "ice"

  def install
    ENV.O2 # Os causes performance issues
    args = [
      "prefix=#{prefix}",
      "V=1",
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
