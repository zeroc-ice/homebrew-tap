require 'formula'

class Icetouch36 < Formula
  homepage 'https://zeroc.com'

  url 'https://github.com/zeroc-ice/icetouch/archive/v3.6.0.tar.gz'
  sha1 ''

  devel do
    url 'https://github.com/zeroc-ice/icetouch.git', :branch => '3.6'
  end

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
