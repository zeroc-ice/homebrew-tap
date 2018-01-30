class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.0"
  revision 1

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "672ba89f183f08aa258498477dfb300db623f2587023dd7d97ce703f64fb4ce3" => :high_sierra
    sha256 "da71de2530d7770aedbabc6d3a36df085c5e649f32b55c49ce771ac6c0f54f29" => :sierra
  end

  depends_on "ice"
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
