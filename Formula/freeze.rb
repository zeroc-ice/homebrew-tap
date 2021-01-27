class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.5"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "dc50dbd42e3584afc550df0710fd9646662eebefed67ffa7a4ae6cfe2c205d4e" => :big_sur
  end

  depends_on "zeroc-ice/tap/ice"
  depends_on "zeroc-ice/tap/berkeley-db@5.3"

  def install
    args = [
      "prefix=#{prefix}",
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
