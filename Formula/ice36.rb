class Ice36 < Formula
  desc "A comprehensive RPC framework with support for C++, .NET, Java, Python, JavaScript and more"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.6.0.tar.gz"
  sha1 ""

  option "with-java-8", "Compile with Java 8 support."
  option "without-java", "Compile without Java support."

  if build.with? "java-8"
    depends_on :java => "1.8"
  elsif build.with? "java"
    depends_on :java => "1.7"
  end

  depends_on "mcpp"
  depends_on "berkeley-db53"

  def install
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
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
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
    # args << "CXXFLAGS=#{ENV.cflags}"

    cd "cpp" do
      system "make", "install", *args
    end

    cd "objective-c" do
      system "make", "install", *args
    end

    if (build.with? "java" or build.with? "java-8")
      cd "java" do
        system "make", "install", *args
      end
    end

    cd "php" do
      args << "install_phpdir=#{share}/php"
      args << "install_libdir=#{lib}/php/extensions"
      system "make", "install", *args
    end
  end

  def caveats
    <<-EOS.undent
      If you installed with Java support the IceGrid Admin application was installed.

      Run `brew linkapps ice36` to symlink it into /Applications.
    EOS
  end

end
