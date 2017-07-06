class IceBuilderXcode < Formula
  desc "Command-line tool for compiling Slice files in Xcode"
  homepage "https://github.com/zeroc-ice/ice-builder-xcode"
  url "https://github.com/zeroc-ice/ice-builder-xcode/archive/v3.1.0.tar.gz"
  sha256 "96be741976aabba0eecf88ff0867c7b09f9df4d40c03fc08ccb20928d3916a1b"

  def install
    bin.install "icebuilder"
  end

  test do
    system bin/"icebuilder", "--version"
  end
end
