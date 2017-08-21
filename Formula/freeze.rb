class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.0"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "ef140edb1357f843bc1960eebc5cc2643f774e2f77c13fc421719ac77f291baa" => :sierra
  end

  depends_on "zeroc-ice/tap/ice"
  depends_on "zeroc-ice/tap/berkeley-db53"

  def install
    args = [
      "prefix=#{prefix}",
      "V=1",
      "ICE_BIN_DIST=all",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "DB_HOME=#{Formula["berkeley-db53"].opt_prefix}",
      "LANGUAGES=cpp"
    ]

    system "make", "-C", "ice/cpp", "IceUtil", "Slice", "V=1"
    system "make", "install", *args
  end

  test do
    system "#{bin}/slice2freeze", "--dict", "StringIntMap,string,int", "StringIntMap"
  end
end
