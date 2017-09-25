 class BerkeleyDbAT53 < Formula
  desc "High performance key/value database"
  homepage "http://www.oracle.com/technology/products/berkeley-db/index.html"
  url "https://zeroc.com/download/homebrew/db-5.3.28.NC.brew.tar.gz"
  sha256 "8ac3014578ff9c80a823a7a8464a377281db0e12f7831f72cef1fd36cd506b94"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "9f8e7e30b280c470de8b7fdba5144d96e939a6511332da5150d2482f98e21111" => :sierra
    sha256 "69361c93887378937c82c6dace2fb02f71c0ae49ddb78183984eb6fafdeb7f26" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on :java => ["1.7+", :build]

  def install
    # BerkeleyDB dislikes parallel builds
    ENV.deparallelize
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --mandir=#{man}
      --enable-cxx
      --enable-java
    ]

    # Ensure we target Java 7 in case we are building with Java >= 8
    inreplace "dist/Makefile.in", "@JAVACFLAGS@", "@JAVACFLAGS@ -source 1.7 -target 1.7"

    # BerkeleyDB requires you to build everything from the build_unix subdirectory
    cd "build_unix" do
      system "../dist/configure", *args
      system "make", "install"

      # use the standard docs location
      doc.parent.mkpath
      mv prefix/"docs", doc
    end
  end
end
