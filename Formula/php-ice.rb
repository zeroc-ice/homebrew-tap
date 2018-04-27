class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.1.tar.gz"
  sha256 "b1526ab9ba80a3d5f314dacf22674dff005efb9866774903d0efca5a0fab326d"

  depends_on "ice"

  # Allow building against any one php version
  php_versions = %w[php@5.6 php@7.0 php@7.1]
  php_versions.each { |php| depends_on php => :optional }
  depends_on "php" => :recommended unless php_versions.find { |php| build.with? php }

  if php_versions.count { |php| build.with?(php) } > 1
    odie "Only one php formula option can be used."
  end

  def php_formulae
    %w[php php@5.6 php@7.0 php@7.1]
  end

  def install
    php = php_formulae.find { |p| build.with?(p) }

    args = [
      "V=1",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[php].opt_bin}/php-config",
    ]

    Dir.chdir("php")
    system "make", "install", *args
  end

  def ext_config_path(php)
    etc/"php/#{Formula[php].php_version}/conf.d/ext-ice.ini"
  end

  def post_install
    php = php_formulae.find { |p| build.with?(p) }
    path = ext_config_path(php)
    if path.exist?
      inreplace path,
        /extension=.*$/, "extension=#{opt_prefix}/ice.so"
      inreplace path,
        /include_path=.*$/, "include_path=#{opt_prefix}"
    else
      path.write <<~EOS
        [ice]
        extension="#{opt_prefix}/ice.so"
        include_path="#{opt_prefix}"
      EOS
    end
  end

  def caveats
    config_files = php_formulae.map { |p| ext_config_path(p) }.select { |p| p.exist? }
    return unless config_files
    <<~EOS
      The following configuration php extension configuration files exist:

        #{config_files.join("\n  ")}

      Do not forget to remove them upon package removal.
    EOS
  end

  test do
    php = php_formulae.find { |p| build.with?(p) }
    assert_match "ice", shell_output("#{Formula[php].opt_bin}/php -m")
  end
end
