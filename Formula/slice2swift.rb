class Slice2swift < Formula
  desc "slice2swift compiler for Ice for Swift"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7-beta1-swift.tar.gz"
  sha256 "46f3532b3b602935fbfbd4ead51db2fdf5c26d0c052bf351d3bf17b62726764b"

  depends_on "mcpp"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "1570e3bc17083e6e107e933eaf3269ea57c5af1ac2cb3e9298c62e045103b167" => :mojave
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
