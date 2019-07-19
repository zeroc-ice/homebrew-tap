class Slice2swift < Formula
  desc "slice2swift compiler for Ice for Swift"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7-beta2-swift.tar.gz"
  sha256 "1c1a2d168b853878b8665ccb1a01f15216634297610d5287eed6cb913d9bdd3d"

  depends_on "mcpp"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "6bc345be8f125aeeef5df9e6306114520f3cc8a61065fed0c24ca43919f36ab3" => :mojave
  end

  def install
    ENV.O2 # Os causes performance issues

    args = [
      "prefix=#{prefix}",
      "V=1",
      "OPTIMIZE=yes",
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
    ]
    Dir.chdir("cpp")
    system "make", "slice2cpp_install", *args
    system "make", "slice2swift_install", *args

    pkgshare.install "../slice"

    (libexec/"bin").mkpath
    %w[slice2cpp].each do |r|
      mv bin/r, libexec/"bin"
    end

    rm_rf [man/"man1/slice2cpp.1"]
  end

  test do
    (testpath / "Hello.ice").write <<~EOS
      module Test
      {
          interface Hello
          {
              void sayHello();
          }
      }
    EOS
    system "#{bin}/slice2swift", "Hello.ice"
  end
end
