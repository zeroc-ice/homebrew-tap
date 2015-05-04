require 'formula'

class BerkeleyDb53 < Formula
  homepage 'http://www.oracle.com/technology/products/berkeley-db/index.html'
  url 'http://download.oracle.com/berkeley-db/db-5.3.28.NC.tar.gz'
  sha1 '8e8971fb49fff9366cf34db2f04ffbb7ec295cc2'

  keg_only 'Conflicts with berkeley-db in main repository.'

  bottle do
    root_url "https://zeroc.com/download/homebrew/bottles"
    cellar :any
    sha256 "12d644ecddfec4c982bb9ba59dad9a6747a0f1dcb216d5803eb60669e474bb41" => :yosemite
  end

  option 'with-java-8', 'Compile with Java 8 support.'
  option 'without-java', 'Compile without Java support.'

  if build.with? "java-8"
    depends_on :java => "1.8"
  elsif build.with? "java"
    depends_on :java => "1.7"
  end

  # Fix build under Xcode 4.6
  # Double-underscore names are reserved, and __atomic_compare_exchange is now
  # a built-in, so rename this to something non-conflicting.
  patch :p0 do
    url 'https://zeroc.com/download/berkeley-db/berkeley-db.5.3.28.patch'
    sha1 '49b8c3321e881fed18533db22918f7b5f5d571aa'
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

    if build.with? "java" or build.with? "java-8"
      if build.with? "java-8"
        java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home -v 1.8`.chomp
      else
        java_home = ENV["JAVA_HOME"] = `/usr/libexec/java_home -v 1.7`.chomp
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

      args << "--enable-java"
    end

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
