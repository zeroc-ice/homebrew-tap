require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class Php71Ice < AbstractPhp71Extension
  init
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0.tar.gz"
  version "3.7.0"
  sha256 "a6bd6faffb29e308ef8f977e27a526ff05dd60d68a72f6377462f9546c1c544a"

  depends_on "ice"

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
    args = [
      "V=1",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[php_formula].opt_bin}/php-config"
    ]

    Dir.chdir('php')
    system "make", "install", *args
    write_config_file if build.with? "config-file"
  end
end
