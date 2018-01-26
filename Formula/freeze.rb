class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.0"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "47d17ab634bfe70e5168378714526fe42fae0064bb420867df94c7372f779bd9" => :sierra
    sha256 "5132cfccee9cc1feb7fec7b978d8d744a604c9fb9dc7f58245e95996fb05dcf3" => :high_sierra
  end

  depends_on "ice"
  depends_on "berkeley-db@5.3"

  def install
    args = [
      "prefix=#{prefix}",
      "install_mandir=#{share}/man",
      "install_docdir=#{share}/doc/freeze",
      "V=1",
      "ICE_BIN_DIST=all",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "DB_HOME=#{Formula["berkeley-db@5.3"].opt_prefix}",
      "LANGUAGES=cpp"
    ]

    system "make", "-C", "ice/cpp", "IceUtil", "Slice", "V=1"
    system "make", "install", *args
  end

  test do
    system "#{bin}/slice2freeze", "--dict", "StringIntMap,string,int", "StringIntMap"
  end
end
