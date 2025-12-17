class IceAT37 < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/v3.7.10.tar.gz"
  sha256 "b90e9015ca9124a9eadfdfc49c5fba24d3550c547f166f3c9b2b5914c00fb1df"

  bottle do
    root_url "https://download.zeroc.com/homebrew/bottles"
    sha256 cellar: :any, arm64_tahoe: "80706fe6c7149401c4d93a4a0b2313a8fb7c0740518e8cfa66aa6796dd819c81"
  end

  depends_on "lmdb"
  depends_on "mcpp"

    patch :DATA

  def install
    extra_cxxflags = []

    # Workaround for Xcode 16 (LLVM 17) Clang bug that causes:
    # include/Ice/OutgoingAsync.h: error: declaration shadows a local variable [-Werror,-Wshadow-uncaptured-local]
    # Ref: https://github.com/llvm/llvm-project/issues/81307
    # Ref: https://github.com/llvm/llvm-project/issues/71976
    extra_cxxflags << "-Wno-shadow-uncaptured-local" if DevelopmentTools.clang_build_version >= 1600

    # Workaround for macOS 26 SDK
    extra_cxxflags << "-Wno-deprecated-declarations" if DevelopmentTools.clang_build_version >= 1700

    # Workaround for Xcode 26 (Clang 17)
    extra_cxxflags << "-Wno-reserved-user-defined-literal" if DevelopmentTools.clang_build_version >= 1700
    extra_cxxflags << "-Wno-deprecated-dynamic-exception-spec" if DevelopmentTools.clang_build_version >= 1700
    extra_cxxflags << "-Wno-deprecated-copy-with-user-provided-dtor" if DevelopmentTools.clang_build_version >= 1700

    unless extra_cxxflags.empty?
      inreplace "config/Make.rules.Darwin", "-Wdocumentation ", "\\0#{extra_cxxflags.join(" ")} "
    end

    args = [
      "prefix=#{prefix}",
      "V=1",
      "USR_DIR_INSTALL=yes", # ensure slice and man files are installed to share
      "MCPP_HOME=#{Formula["mcpp"].opt_prefix}",
      "LMDB_HOME=#{Formula["lmdb"].opt_prefix}",
      "CONFIGS=all",
      "PLATFORMS=all",
      "SKIP=slice2confluence",
      "LANGUAGES=cpp objective-c",
    ]
    system "make", "install", *args

    (libexec/"bin").mkpath
    %w[slice2py slice2rb slice2js].each do |r|
      mv bin/r, libexec/"bin"
    end
  end

  def caveats
    <<~EOS
      slice2py, slice2js and slice2rb were installed in:

        #{opt_libexec}/bin

      You may wish to add this directory to your PATH.
    EOS
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
    (testpath / "Test.cpp").write <<~EOS
      #include <Ice/Ice.h>
      #include <Hello.h>

      class HelloI : public Test::Hello
      {
      public:
        virtual void sayHello(const Ice::Current&) override {}
      };

      int main(int argc, char* argv[])
      {
        Ice::CommunicatorHolder ich(argc, argv);
        auto adapter = ich->createObjectAdapterWithEndpoints("Hello", "default -h localhost");
        adapter->add(std::make_shared<HelloI>(), Ice::stringToIdentity("hello"));
        adapter->activate();
        return 0;
      }
    EOS

    # Homebrew sets several env variables related to C++ compilation.
    # Some of these (specifically CPATH) break compilation against the iOS SDK.
    ENV.delete("CPATH")
    ENV.delete("CXXFLAGS")
    ENV.delete("CPPFLAGS")
    ENV.delete("CFLAGS")
    ENV.delete("LDFLAGS")
    ENV.delete("SDKROOT")

    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", "-I#{include}", "-I.", "Hello.cpp"
    system "xcrun", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", "-I#{include}", "-I.", "Test.cpp"
    system "xcrun", "clang++", "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce++11", "-lpthread"
    system "./test"
    # Test the iOS SDK
    system "#{bin}/slice2cpp", "Hello.ice"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Hello.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-DICE_CPP11_MAPPING", "-std=c++17", "-c", \
            "-I#{prefix}/sdk/macosx.sdk/usr/include", "-I.", "Test.cpp"
    system "xcrun", "--sdk", "macosx", "clang++", "-L#{prefix}/sdk/macosx.sdk/usr/lib", "-o", "test-sdk", \
            "Test.o", "Hello.o", "-lIce++11", "-framework", "Security", "-framework", "Foundation", \
            "-lbz2", "-liconv"
    system "./test-sdk"
  end
end

__END__
diff --git a/objective-c/src/Ice/Object.mm b/objective-c/src/Ice/Object.mm
index 21c8368802..a4b3471d2d 100644
--- a/objective-c/src/Ice/Object.mm
+++ b/objective-c/src/Ice/Object.mm
@@ -330,7 +330,7 @@ static NSString* ICEObject_ids[1] =
 -(BOOL) ice_isA:(NSString*)__unused typeId current:(ICECurrent*)__unused current
 {
     NSAssert(NO, @"ice_isA requires override");
-    return nil;
+    return NO;
 }
 -(void) ice_ping:(ICECurrent*)__unused current
 {
