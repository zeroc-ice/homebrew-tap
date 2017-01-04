require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class Php71Ice37a < AbstractPhp71Extension
  init
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice.git", :branch => "master"
  version "3.7a4"

  depends_on "ice37a"

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
      "prefix=#{Formula["ice37a"].opt_prefix}",
      "embedded_runpath_prefix=#{Formula["ice37a"].opt_prefix}",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice37a"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[php_formula].opt_bin}/php-config"
    ]

    Dir.chdir('php')
    system "make", "install", *args
    write_config_file if build.with? "config-file"
  end
end
