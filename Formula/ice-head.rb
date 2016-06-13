class IceHead < Formula
  desc "A comprehensive RPC framework with support for C++, .NET, Java, Python, JavaScript and more"
  homepage "https://zeroc.com"
  head "https://github.com/zeroc-ice/ice.git"

  option "with-java", "Build Ice for Java and the IceGrid Admin app"
  option "with-xcode-sdk", "Build Xcode SDK for iOS development (includes static libs)."

  depends_on "mcpp"
  depends_on "lmdb"
  depends_on :java => [ "1.8+", :optional]
  depends_on :macos => :mavericks

  def install

    # Unset ICE_HOME as it interferes with the build
    ENV.delete("ICE_HOME")
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    args = [
      "prefix=#{prefix}",
      "embedded_runpath_prefix=#{prefix}",
      "install_phpdir=#{share}/php",
      "install_phplibdir=#{lib}/php/extensions",
      "OPTIMIZE=yes",
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "CONFIGS=shared cpp11-shared #{(build.with? 'xcode-sdk') ? 'xcodesdk cpp11-xcodesdk' : ''}",
      "PLATFORMS=#{(build.with? 'xcode-sdk') ? 'all' : 'macos'}",
      "SKIP=slice2py slice2rb slice2js",
      "LANGUAGES=cpp objective-c php #{(build.with? 'java') ? 'java' : ''}"
    ]
    system "make", "install", *args
  end
end
