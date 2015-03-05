require 'formula'

class Ice36b < Formula
  homepage 'http://www.zeroc.com'
  url 'https://www.zeroc.com/download/Ice/3.6/Ice-3.6b.tar.gz'
  sha1 'dcab7e14b3e42fa95af58f7e804f6fd9a17cb6b2'
  revision 3

  bottle do
    root_url "https://www.zeroc.com/download/homebrew/bottles"
    cellar :any
    revision 1
    sha256 "317e025a334f7db3f43733c3e441d1f63f00735eb43b68f370b99eceaf4172aa" => :yosemite
  end

  option 'without-java', 'Compile without Java support.'

  depends_on 'mcpp'
  depends_on 'berkeley-db53'

  patch do
    url "https://raw.githubusercontent.com/ZeroC-Inc/homebrew-ice/master/Patches/ice-3.6b.brew.patch"
    sha1 "c4b75db8cd209b0c796d76b242ba7671237107ca"
  end

  def install
    inreplace "cpp/src/slice2py/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2rb/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2js/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end

    if build.without? "java"
      inreplace "cpp/src/slice2java/Makefile" do |s|
          s.sub! /install:/, "dontinstall:"
      end
      inreplace "cpp/src/slice2freezej/Makefile" do |s|
          s.sub! /install:/, "dontinstall:"
      end
    end

    # Unset ICE_HOME as it interferes with the build
    ENV.delete('ICE_HOME')
    ENV.delete('USE_BIN_DIST')
    ENV.delete('CPPFLAGS')
    ENV.O2

    args = %W[
      prefix=#{prefix}
      embedded_runpath_prefix=#{prefix}
      USR_DIR_INSTALL=yes
      OPTIMIZE=yes
      DB_HOME=#{HOMEBREW_PREFIX}/opt/berkeley-db53
    ]
    #
    # Setting this gets rid of the optimization level and the arch flags.
    #
    #args << "CXXFLAGS=#{ENV.cflags}"

    cd "cpp" do
      system "make", "install", *args
    end

    cd "php" do
        args << "install_phpdir=#{lib}/share/php"
        args << "install_libdir=#{lib}/php/extensions"
        system "make", "install", *args
    end
  end

  test do
    system "#{bin}/icebox", "--version"
  end

  def caveats
    <<-EOS.undent
      To enable IcePHP, you will need to change your php.ini
      to load the IcePHP extension. You can do this by adding
      IcePHP.dy to your list of extensions:

          extension=#{prefix}/lib/php/extensions/IcePHP.dy

      Typical Ice PHP scripts will also expect to be able to 'require Ice.php'.

      You can ensure this is possible by appending the path to
      Ice's PHP includes to your global include_path in php.ini:

          include_path=<your-original-include-path>:#{prefix}/lib/share/php

      However, you can also accomplish this on a script-by-script basis
      or via .htaccess if you so desire...
      EOS
  end
end
