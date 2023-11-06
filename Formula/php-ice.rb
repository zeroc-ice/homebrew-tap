class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.10.tar.gz"
  sha256 "b90e9015ca9124a9eadfdfc49c5fba24d3550c547f166f3c9b2b5914c00fb1df"

  bottle do
    root_url "https://download.zeroc.com/homebrew/bottles"
    sha256 cellar: :any, arm64_sonoma: "7a75ab716956d58d99d85773684c80191eed42275d84758232b2a7c6f7f6dbd7"
  end

  depends_on "php"
  depends_on "zeroc-ice/tap/ice"

  def install
    args = [
      "ICE_BIN_DIST=cpp",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "OPTIMIZE=yes",
      "PHP_CONFIG=#{Formula["php"].opt_bin}/php-config",
      "USR_DIR_INSTALL=yes",
      "V=1",
    ]

    system "make", "-C", "php", "install", *args
  end

  def ext_config_path
    etc/"php/#{Formula["php"].version.major_minor}/conf.d/ext-ice.ini"
  end

  def post_install
    if ext_config_path.exist?
      inreplace ext_config_path,
        /extension=.*$/, "extension=#{opt_prefix}/ice.so"
      inreplace ext_config_path,
        /include_path=.*$/, "include_path=#{opt_prefix}"
    else
      ext_config_path.write <<~EOS
        [ice]
        extension="#{opt_prefix}/ice.so"
        include_path="#{opt_prefix}"
      EOS
    end
  end

  def caveats
    <<~EOS
      The following configuration file was generated:

          #{ext_config_path}

      Do not forget to remove it upon package removal.
    EOS
  end

  test do
    assert_match "ice", shell_output("#{Formula["php"].opt_bin}/php -m")
  end
end
