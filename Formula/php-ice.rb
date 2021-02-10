class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.5.tar.gz"
  sha256 "36bf45591a95e6ee7216153d45d8eca05ff00c1da35608f0c400e6ddc8049da9"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    sha256 cellar: :any_skip_relocation, big_sur: "d89c053522516fe6cf191838bf1ea9a5f9bca4860703dc6bc4f48b51e3216eb8"
  end

  depends_on "php"
  depends_on "zeroc-ice/tap/ice"

  def install
    args = [
      "V=1",
      "USR_DIR_INSTALL=yes",
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
