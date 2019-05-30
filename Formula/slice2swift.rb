class Slice2swift < Formula
    desc "slice2swift compiler for Ice for Swift"
    homepage "https://zeroc.com"
    url "https://github.com/zeroc-ice/ice.git", :tag => "swift"
    version "3.7.2-swift"

    depends_on "mcpp"

    def install
      ENV.O2 # Os causes performance issues

      args = [
        "prefix=#{prefix}",
        "V=1",
        "OPTIMIZE=yes",
        "MCPP_HOME=#{Formula["mcpp"].opt_prefix}"
      ]
      Dir.chdir("cpp")
      system "make", "slice2cpp_install", *args
      system "make", "slice2swift_install", *args

      (libexec/"bin").mkpath
      %w[slice2cpp].each do |r|
        mv bin/r, libexec/"bin"
      end

      rm_rf [man/"man1/slice2cpp.1"]
    end

    test do
      (testpath / "Hello.ice").write <<~EOS
        module Test
        {
            interface Hello
            {
                void sayHello();
            }
        }
      EOS
      system "#{bin}/slice2swift", "Hello.ice"
    end
end
