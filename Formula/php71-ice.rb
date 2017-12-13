require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class Php71Ice < AbstractPhp71Extension
  init
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0.tar.gz"
  sha256 "809fff14a88a7de1364c846cec771d0d12c72572914e6cc4fb0b2c1861c4a1ee"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "59ce93bd836381507fc701b0981c3655c6fa9d4828437e0cfee1d63890e16c3e" => :sierra
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
