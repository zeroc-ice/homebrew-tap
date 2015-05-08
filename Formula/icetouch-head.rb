require 'formula'

class IcetouchHead < Formula
  homepage 'https://zeroc.com'
  head 'https://github.com/zeroc-ice/icetouch.git'

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
end
