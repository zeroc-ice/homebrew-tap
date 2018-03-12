require File.expand_path("../Abstract/abstract-php-extension", __dir__)

class Php70Ice < AbstractPhp70Extension
  init
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0.tar.gz"
  sha256 "809fff14a88a7de1364c846cec771d0d12c72572914e6cc4fb0b2c1861c4a1ee"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "4e65fa1bcf9d232fded9138bfdc26026b6ddd7ab84f699ebf47d3e7712b62a3f" => :sierra
  end

  depends_on "ice"

  def config_file
    <<-EOS.undent
      [#{extension}]
      #{extension_type}="#{module_path}"
      include_path="#{opt_prefix}"
      EOS
  rescue StandardError
    nil
  end

  def install
    args = [
      "V=1",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[php_formula].opt_bin}/php-config",
    ]

    Dir.chdir("php")
    system "make", "install", *args
    write_config_file if build.with? "config-file"
  end
end
