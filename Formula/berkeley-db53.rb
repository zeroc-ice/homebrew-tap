class BerkeleyDb53 < Formula
  desc "High performance key/value database"
  homepage "http://www.oracle.com/technology/products/berkeley-db/index.html"
  url "https://zeroc.com/download/homebrew/db-5.3.28.NC.brew.tar.gz"
  sha256 "8ac3014578ff9c80a823a7a8464a377281db0e12f7831f72cef1fd36cd506b94"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "799ccfdf9548acfeeb3dd7f5f479be355b1bd24ba07985c5bee992e11ab85eca" => :yosemite
    sha256 "ac370029c8a5160598f1d2171beb5a29637634827bf3b607821ef76963cdd532" => :el_capitan
  end

  keg_only "Conflicts with berkeley-db in main repository."

  depends_on :java => ["1.7+", :recommended]

  def install
    # BerkeleyDB dislikes parallel builds
    ENV.deparallelize
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --mandir=#{man}
      --enable-cxx
    ]

    if build.with? "java"
      args << "--enable-java"
      inreplace "dist/Makefile.in", "@JAVACFLAGS@", "@JAVACFLAGS@ -source 1.7 -target 1.7"
    end

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
