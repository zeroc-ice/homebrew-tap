class Freeze < Formula
  desc "Persistent Storage for Ice Objects"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/freeze.git", :tag => "v3.7.2"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "59c893dd8aa6d339a9fee5dd117d9c90d4e8c9cb535687a2ce006fb42ad244cf" => :mojave
    sha256 "2df5be2cf5da1cefdac3bd0760bc60ce287c1028aa528e5a6bde541a5f72881d" => :high_sierra
    sha256 "2523ee1e82261ef310297214629992547c643f8c1c33ca5aae4fc5c46775c63e" => :sierra
  end

  depends_on "zeroc-ice/tap/ice"
  depends_on "zeroc-ice/tap/berkeley-db@5.3"

  def install
    ENV.O2 # Os causes performance issues
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
