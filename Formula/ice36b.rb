require 'formula'

class Ice36b < Formula
  homepage 'http://www.zeroc.com'
  url 'https://www.zeroc.com/download/Ice/3.6/Ice-3.6b.tar.gz'
  sha1 'dcab7e14b3e42fa95af58f7e804f6fd9a17cb6b2'

  option 'with-java', 'Compile with Java support.'
  option 'with-java7', 'Compile with Java 7 support.'

  depends_on 'mcpp'

  resource "berkeley-db" do
    url "http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
    sha1 "fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9"
  end

  resource "berkeley-db-patch" do
    url "https://raw.githubusercontent.com/ZeroC-Inc/homebrew-ice/master/Patches/berkeley-db.5.3.28.patch"
    sha1 "49b8c3321e881fed18533db22918f7b5f5d571aa"
  end

  patch do
    url "https://raw.githubusercontent.com/ZeroC-Inc/homebrew-ice/master/Patches/ice-3.6b.brew.patch"
    sha1 "ed9edb61583ae8b9d72070b086147bbb8a557ade"
  end

  def install
    resource("berkeley-db").stage do
      (Pathname.pwd).install resource("berkeley-db-patch")
      system "/usr/bin/patch", "-p0", "-i", "berkeley-db.5.3.28.patch"

      # BerkeleyDB dislikes parallel builds
      ENV.deparallelize

      ENV.O3

      # --enable-compat185 is necessary because our build shadows
      # the system berkeley db 1.x
      args = %W[
        --disable-debug
        --prefix=#{libexec}
        --mandir=#{libexec}/man
        --enable-cxx
        --enable-compat185
      ]

      if build.with? "java" or build.with? "java7"
        if build.with? "java7"
          java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home -v 1.7`.chomp
        else
          java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
        end

        # The Oracle JDK puts jni.h into #{java_home}/include and jni_md.h into
        # #{java_home}/include/darwin.  The original Apple/SUN JDK placed jni.h
        # and jni_md.h into
        # /System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/
        #
        # Setup the include path with the Oracle JDK location first and the Apple JDK location second.
        ENV.append('CPPFLAGS', "-I#{java_home}/include")
        ENV.append('CPPFLAGS', "-I#{java_home}/include/darwin")
        ENV.append('CPPFLAGS', "-I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/")

        # This doesn't work at present.
        #ENV.O3
        #ENV.append_to_cflags("-I#{java_home}/include")
        #ENV.append_to_cflags("-I#{java_home}/include/darwin")
        #ENV.append_to_cflags("-I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/")
      end

      args << "--enable-java" if build.with? "java" or build.with? "java7"

      # BerkeleyDB requires you to build everything from the build_unix subdirectory
      cd 'build_unix' do
        system "../dist/configure", *args
        system "make", "install"
      end
    end

    inreplace "cpp/src/slice2py/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2rb/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2js/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end

    if not (build.with? "java" or build.with? "java7")
      inreplace "cpp/src/slice2java/Makefile" do |s|
          s.sub! /install:/, "dontinstall:"
      end
      inreplace "cpp/src/slice2freezej/Makefile" do |s|
          s.sub! /install:/, "dontinstall:"
      end
    end

    # Unset ICE_HOME as it interferes with the build
    ENV.delete('ICE_HOME')
    ENV.delete('CPPFLAGS')
    ENV.O2

    args = %W[
      prefix=#{prefix}
      embedded_runpath_prefix=#{prefix}
      USR_DIR_INSTALL=yes
      OPTIMIZE=yes
      DB_HOME=#{libexec}
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

          extension=#{prefix}/php/IcePHP.dy

      Typical Ice PHP scripts will also expect to be able to 'require Ice.php'.

      You can ensure this is possible by appending the path to
      Ice's PHP includes to your global include_path in php.ini:

          include_path=<your-original-include-path>:#{prefix}/php

      However, you can also accomplish this on a script-by-script basis
      or via .htaccess if you so desire...
      EOS
  end
end
