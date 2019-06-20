class Slice2swift < Formula
  desc "slice2swift compiler for Ice for Swift"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.2-beta1-swift.tar.gz"
  sha256 "2ef449d7c809191b0e50dabe1aabab24124b9d8581d7f56e1a7c77dc17c26951"

  depends_on "mcpp"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "1a5cd54914657fb6afc88d84e1cb394f1fa7eba873c2cc0c57ab8c588d44ba08" => :mojave
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
