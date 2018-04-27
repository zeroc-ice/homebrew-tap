module Language
  module PHP
    def self.versions
      %w[php@5.6 php@7.0 php@7.1]
    end

    def self.formulae
      %w[php] + self.versions
    end

    def self.get(build)
      v = self.versions.find { |p| build.with? p }
      v ? v : "php"
    end
  end
end

class PhpIce < Formula
  desc "Ice for PHP"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.1.tar.gz"
  sha256 "b1526ab9ba80a3d5f314dacf22674dff005efb9866774903d0efca5a0fab326d"

  depends_on "ice"

  Language::PHP.versions.each { |php|
    option "with-#{php}", "Build for #{php} "
    depends_on php => :optional
  }
  depends_on "php" unless Language::PHP.versions.any? { |php| build.with? php }

  if Language::PHP.versions.count { |php| build.with? php } > 1
    odie "Please specify a single php version option or no option to use the latest"
  end

  def install
    args = [
      "V=1",
      "install_phpdir=#{prefix}",
      "install_phplibdir=#{prefix}",
      "OPTIMIZE=yes",
      "ICE_HOME=#{Formula["ice"].opt_prefix}",
      "ICE_BIN_DIST=cpp",
      "PHP_CONFIG=#{Formula[Language::PHP.get(build)].opt_bin}/php-config",
    ]

    Dir.chdir("php")
    system "make", "install", *args
  end

  def ext_config_path(php)
    etc/"php/#{Formula[php].php_version}/conf.d/ext-ice.ini"
  end

  def post_install
    php = Language::PHP.get(build)
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
    config_files = Language::PHP.formulae.map { |p| ext_config_path(p) }.select { |p| p.exist? }
    return unless config_files
    <<~EOS
      The following php extension configuration files exist:

        #{config_files.join("\n  ")}

      Do not forget to remove them upon package removal.
    EOS
  end

  test do
    php = Language::PHP.get(build)
    assert_match "ice", shell_output("#{Formula[php].opt_bin}/php -m")
  end
end
