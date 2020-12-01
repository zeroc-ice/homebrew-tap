class BerkeleyDbAT53 < Formula
  desc "High performance key/value database"
  homepage "http://www.oracle.com/technology/products/berkeley-db/index.html"
  url "https://zeroc.com/download/homebrew/db-5.3.28.NC.brew.tar.gz"
  sha256 "8ac3014578ff9c80a823a7a8464a377281db0e12f7831f72cef1fd36cd506b94"

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "a404ddc506a8bfc68951c22773a04da62fd6daf5c60a82a736994fe4046b1044" => :mojave
    sha256 "69361c93887378937c82c6dace2fb02f71c0ae49ddb78183984eb6fafdeb7f26" => :high_sierra
    sha256 "9f8e7e30b280c470de8b7fdba5144d96e939a6511332da5150d2482f98e21111" => :sierra
  end

  keg_only :versioned_formula

  depends_on "openjdk@8" => :build

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

    # Fix issue with Clang build
    ["src/dbinc/atomic.h",
     "src/mp/mp_fget.c",
     "src/mutex/mut_method.c",
     "src/mutex/mut_tas.c",
     "src/mp/mp_mvcc.c",
     "src/mp/mp_region.c"].each do |f|
      inreplace f, "atomic_init", "atomic_init_db"
    end

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

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <assert.h>
      #include <string.h>
      #include <db_cxx.h>
      int main() {
        Db db(NULL, 0);
        assert(db.open(NULL, "test.db", NULL, DB_BTREE, DB_CREATE, 0) == 0);

        const char *project = "Homebrew";
        const char *stored_description = "The missing package manager for macOS";
        Dbt key(const_cast<char *>(project), strlen(project) + 1);
        Dbt stored_data(const_cast<char *>(stored_description), strlen(stored_description) + 1);
        assert(db.put(NULL, &key, &stored_data, DB_NOOVERWRITE) == 0);

        Dbt returned_data;
        assert(db.get(NULL, &key, &returned_data, 0) == 0);
        assert(strcmp(stored_description, (const char *)(returned_data.get_data())) == 0);

        assert(db.close(0) == 0);
      }
    EOS
    flags = %W[
      -I#{include}
      -L#{lib}
      -ldb_cxx
    ]
    system ENV.cxx, "test.cpp", "-o", "test", *flags
    system "./test"
    assert_predicate testpath/"test.db", :exist?
  end
end
