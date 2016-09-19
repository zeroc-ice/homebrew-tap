class IceBuilderXcode < Formula
  desc "Helps compiling Slice files to C++ or Objective-C in Xcode"
  homepage "https://github.com/zeroc-ice/ice-builder.xcode"
  url "https://github.com/zeroc-ice/ice-builder-xcode/archive/v3.0.0.tar.gz"
  sha256 "498c2d897143c6781b481244ce254da469ca1de3384fb011974c94fca857b3c8"

  def install
    bin.install "icebuilder"
  end

  test do
    system bin/"xmake", "-v"
  end
end
