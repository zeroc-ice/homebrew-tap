class IceBuilderXcode < Formula
  desc "Helps compiling Slice files to C++ or Objective-C in Xcode"
  homepage "https://github.com/zeroc-ice/ice-builder.xcode"
  url "https://github.com/zeroc-ice/ice-builder-xcode/archive/v3.0.1.tar.gz"
  sha256 "d9206ef562473ef66ff4cc3a8a91687e982c165a9584ae4ce7ca786ca3daef89"

  def install
    bin.install "icebuilder"
  end

  test do
    system bin/"icebuilder", "--version"
  end
end
