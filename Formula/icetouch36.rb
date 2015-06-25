class Icetouch36 < Formula
  homepage "https://zeroc.com"

  url "https://github.com/zeroc-ice/icetouch.git", :tag => "v3.6.0"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "a738beec0f989d505b4070a4a8e0a64d213fcfb33e139d0172a79cfb8fbd21ac" => :yosemite
  end

  depends_on "mcpp"

  def install
    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    args = %W[
      prefix=#{prefix}
      OPTIMIZE=yes
    ]

    system "make", "install", *args
  end
end
