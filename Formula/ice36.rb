class Ice36 < Formula
  desc "A comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.6.0.tar.gz"
  sha256 "77933580cdc7fade0ebfce517935819e9eef5fc6b9e3f4143b07404daf54e25e"

  bottle do
    cellar :any
    revision 1
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "c2e6453a184bb2276689ce72e856c66b43e8962a5bed40b14750536dfe4b53a2" => :yosemite
  end

  option "with-java", "Build Ice for Java and the IceGrid Admin app"

  depends_on "berkeley-db53"
  depends_on "mcpp"
  depends_on :java => :optional
  depends_on :macos => :mavericks

  def install
     inreplace "cpp/src/slice2js/Makefile", /install:/, "dontinstall:"

    if build.with? "java"
      inreplace "java/src/IceGridGUI/build.gradle", "${DESTDIR}${binDir}/${appName}.app",  "${prefix}/${appName}.app"
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

    cd "cpp" do
      system "make", "install", *args
    end

    cd "objective-c" do
      system "make", "install", *args
    end

    if build.with? "java"
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
end
