require 'formula'

class BerkeleyDb53 < Formula
  homepage 'http://www.oracle.com/technology/products/berkeley-db/index.html'
  url 'http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz'
  sha1 'fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9'

  keg_only 'Conflicts with berkeley-db in main repository.'

  bottle do
    cellar :any
    revision 1
    sha1 "a134b5effaa73fd296b2601180520292c0a6d095" => :yosemite
    sha1 "910660e253bf32a1ce730d4ba27e3090f645f5f6" => :mavericks
    sha1 "aaafa41026335a6b7e6c0792d1511325c79409fa" => :mountain_lion
  end

  option 'with-java', 'Compile with Java support.'
  option 'with-java7', 'Compile with Java support.'
  option 'enable-sql', 'Compile with SQL support.'

  # Fix build under Xcode 4.6
  # Double-underscore names are reserved, and __atomic_compare_exchange is now
  # a built-in, so rename this to something non-conflicting.
  patch :p0 do
    url "https://raw.githubusercontent.com/ZeroC-Inc/homebrew-ice/master/Patches/berkeley-db.5.3.28.patch"
    sha1 "49b8c3321e881fed18533db22918f7b5f5d571aa"
  end

  def install
    # BerkeleyDB dislikes parallel builds
    ENV.deparallelize
    # --enable-compat185 is necessary because our build shadows
    # the system berkeley db 1.x
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --mandir=#{man}
      --enable-cxx
      --enable-compat185
    ]

    if build.with? "java" or build.with? "java7"
      if build.with? "java7"
        java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home -v 1.7`.chomp
      else
        java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
      end

      # The Oracle JDK puts jni.h into #{java_home}/include and jni_md.h into
      # #{java_home}/include/darwin.  The original Apple/SUN JDK placed jni.h
      # and jni_md.h into
      # /System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/
      #
      # Setup the include path with the Oracle JDK location first and the Apple JDK location second.
      ENV.append('CPPFLAGS', "-I#{java_home}/include")
      ENV.append('CPPFLAGS', "-I#{java_home}/include/darwin")
      ENV.append('CPPFLAGS', "-I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/")

      # This doesn't work at present.
      #ENV.O3
      #ENV.append_to_cflags("-I#{java_home}/include")
      #ENV.append_to_cflags("-I#{java_home}/include/darwin")
      #ENV.append_to_cflags("-I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/")
    end

    args << "--enable-java" if build.with? "java" or build.with? "java7"
    args << "--enable-sql" if build.include? "enable-sql"

    # BerkeleyDB requires you to build everything from the build_unix subdirectory
    cd 'build_unix' do
      system "../dist/configure", *args
      system "make install"

      # use the standard docs location
      doc.parent.mkpath
      mv prefix/'docs', doc
    end
  end
end
