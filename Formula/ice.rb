require 'formula'

class Ice < Formula
  homepage 'https://zeroc.com'
  head 'https://github.com/ZeroC-Inc/ice-dev.git'

  option 'without-java', 'Compile without Java support.'

  depends_on 'mcpp'
  depends_on 'berkeley-db53'

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

    cd "objective-c" do
      system "make", "install", *args
    end

    cd "php" do
        args << "install_phpdir=#{lib}/share/php"
        args << "install_libdir=#{lib}/php/extensions"
        system "make", "install", *args
    end
  end

  test do
    system "#{bin}/slice2cpp", "--version"
    system "#{bin}/icebox", "--version"
  end

  # def caveats
  #   <<-EOS.undent
  #     To enable IcePHP, you will need to change your php.ini
  #     to load the IcePHP extension. You can do this by adding
  #     IcePHP.dy to your list of extensions:

  #         extension=#{prefix}/lib/php/extensions/IcePHP.dy

  #     Typical Ice PHP scripts will also expect to be able to 'require Ice.php'.

  #     You can ensure this is possible by appending the path to
  #     Ice's PHP includes to your global include_path in php.ini:

  #         include_path=<your-original-include-path>:#{prefix}/lib/share/php

  #     However, you can also accomplish this on a script-by-script basis
  #     or via .htaccess if you so desire...
  #     EOS
  # end
end
