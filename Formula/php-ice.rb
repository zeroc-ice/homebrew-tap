class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.2.tar.gz"
  sha256 "e329a24abf94a4772a58a0fe61af4e707743a272c854552eef3d7833099f40f9"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "5b8f5a96019c11eabf2018570ca4254b3d16cc90612befb50ae7c4830cffdde1" => :mojave
    sha256 "34e2ae545c2d6efeb6bbe8ef1b543f925444c476a2879428db91ef2504259479" => :high_sierra
    sha256 "3f8f59ecd52817e96700d63199c45e473ef190bf63771cdf3f68f2158781b397" => :sierra
  end

  depends_on "php"
  depends_on "zeroc-ice/dist-utils/ice" # always test against a dist-utils build

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
