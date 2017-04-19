require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class Php56Ice37b0 < AbstractPhp56Extension
  init
  desc "Ice for PHP 5.6"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0-beta0.tar.gz"
  version "3.7b0"
  sha256 "2ce1ee772e1f8424af867ba69796fcfdf1a67dc8816c192705e8363343a6575f"

  bottle do
    root_url "https://dev.zeroc.com/share/ice/v3.7.0-beta0/brew"
    sha256 "9bf7b7e982f68c72d56c1143d9f6468b3c6fa0593d807f402e76c92d8d0c41af" => :sierra
  end

  depends_on "ice37b0"

  def module_path
    opt_prefix / "IcePHP.so"
  end

  def config_file
    begin
      <<-EOS.undent
      [#{extension}]
      #{extension_type}="#{module_path}"
      include_path="#{opt_prefix}"
      EOS
    rescue Exception
      nil
    end
  end

  def install
    # Unset variables which interfere with the build
    ENV.delete("USE_BIN_DIST")
    ENV.delete("CPPFLAGS")
    ENV.O2

    args = [
      "prefix=#{Formula["ice37b0"].opt_prefix}",
      "embedded_runpath_prefix=#{Formula["ice37b0"].opt_prefix}",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice37b0"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[php_formula].opt_bin}/php-config"
    ]

    Dir.chdir('php')
    system "make", "install", *args
    write_config_file if build.with? "config-file"
  end
end
