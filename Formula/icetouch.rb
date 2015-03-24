require 'formula'

class Icetouch < Formula
  homepage 'https://zeroc.com'
  head 'https://github.com/ZeroC-Inc/icetouch.git'

  depends_on 'mcpp'

  def install

    # Unset ICE_HOME as it interferes with the build
    ENV.delete('ICE_HOME')
    ENV.delete('USE_BIN_DIST')
    ENV.delete('CPPFLAGS')
    ENV.O2

    args = %W[
      prefix=#{prefix}
      OPTIMIZE=yes
    ]

    system "make", "install", *args

  end

  test do
    system "#{bin}/slice2objc", "--version"
  end
end
