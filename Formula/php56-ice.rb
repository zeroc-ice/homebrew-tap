require File.expand_path("../../Abstract/abstract-php-extension", __FILE__)

class Php56Ice < AbstractPhp56Extension
  init
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.0.tar.gz"
  version "3.7.0"
  sha256 "a6bd6faffb29e308ef8f977e27a526ff05dd60d68a72f6377462f9546c1c544a"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 "96048575b0af55fbff8246c302421dea98ceb21f63818eba32a409cedfdd12c7" => :sierra
  end

  depends_on "zeroc-ice/tap/ice"

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
