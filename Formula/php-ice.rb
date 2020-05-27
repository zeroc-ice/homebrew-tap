class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.4.tar.gz"
  sha256 "57f200bd2916799bce12960e579d9f9e5b6a9801addaf93d97bb4ce15c760a44"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "0a6e84e94c33eca14624b46441d93b0a73f5976e114d98c411ca6cfc0a7d26a4" => :catalina
  end

  depends_on "php"
  depends_on "zeroc-ice/tap/ice"

  def install
    args = [
      "V=1",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula["php"].opt_bin}/php-config",
    ]

    Dir.chdir("php")
    system "make", "install", *args
  end

  def ext_config_path
    etc/"php/#{Formula["php"].php_version}/conf.d/ext-ice.ini"
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
