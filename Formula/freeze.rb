class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.1"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "b12c972a070b963aca72a37609d646e5c3f29356e8b6debb254ec9457da1eb18" => :high_sierra
    sha256 "1317fb9a27f25baecb83b94f2db1066289f284a528db697316a0b980a4f1cab5" => :sierra
  end

  depends_on "zeroc-ice/tap/ice"
  depends_on "berkeley-db@5.3"

  def install
    ENV.O2 # Os causes performance issues
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
