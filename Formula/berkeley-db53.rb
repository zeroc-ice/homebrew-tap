class BerkeleyDb53 < Formula
  homepage "http://www.oracle.com/technology/products/berkeley-db/index.html"
  url "http://download.oracle.com/berkeley-db/db-5.3.28.NC.tar.gz"
  sha1 "8e8971fb49fff9366cf34db2f04ffbb7ec295cc2"

  keg_only "Conflicts with berkeley-db in main repository."

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "12d644ecddfec4c982bb9ba59dad9a6747a0f1dcb216d5803eb60669e474bb41" => :yosemite
  end

  depends_on :java => :recommended

  # Fix build under Xcode 4.6
  # Double-underscore names are reserved, and __atomic_compare_exchange is now
  # a built-in, so rename this to something non-conflicting.
  patch :p0 do
    url "https://zeroc.com/download/berkeley-db/berkeley-db.5.3.28.patch"
    sha1 "49b8c3321e881fed18533db22918f7b5f5d571aa"
  end

  def install
    # BerkeleyDB dislikes parallel builds
    ENV.deparallelize
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --mandir=#{man}
      --enable-cxx
    ]

    args << "--enable-java" if build.with? "java"

    # BerkeleyDB requires you to build everything from the build_unix subdirectory
    cd "build_unix" do
      system "../dist/configure", *args
      system "make install"

      # use the standard docs location
      doc.parent.mkpath
      mv prefix/"docs", doc
    end
  end
end
