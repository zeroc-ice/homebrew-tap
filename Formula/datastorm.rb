class Datastorm < Formula
  desc "Data centric publish subscribe"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/datastorm/archive/v0.1.0.tar.gz"
  sha256 "e62cd1cc4c2f49294db80a6e8fa316e17ef1e64aa5d704e9f95fddc1e244eedc"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "235a3e40cc7af0a48a0431bf6f0872fffa3139147cc57a1bebed4770918867a6" => :mojave
    sha256 "336655ff5225da962724d592a70a3d829f20b99e3999f81c2cdfbc29efad55df" => :high_sierra
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
    system "xcrun", "clang++", "-L#{lib}", "-L#{Formula["ice"].lib}", "-o", "test", "Test.o", "-lDataStorm", "-lIce++11"
    system "./test"
  end
end
