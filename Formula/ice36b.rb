require 'formula'

class Ice36b < Formula
  homepage 'http://www.zeroc.com'
  url 'https://www.zeroc.com/download/Ice/3.6/Ice-3.6b.tar.gz'
  sha1 'dcab7e14b3e42fa95af58f7e804f6fd9a17cb6b2'

  depends_on 'berkeley-db'
  depends_on 'mcpp'

  patch :DATA

  def install
    ENV.O2

    inreplace "cpp/src/slice2py/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2rb/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end
    inreplace "cpp/src/slice2js/Makefile" do |s|
        s.sub! /install:/, "dontinstall:"
    end

    args = %W[
      prefix=#{prefix}
      embedded_runpath_prefix=#{prefix}
      USR_DIR_INSTALL=yes
      OPTIMIZE=yes
    ]
    args << "CXXFLAGS=#{ENV.cflags}"

    # Unset ICE_HOME as it interferes with the build
    ENV.delete('ICE_HOME')

    cd "cpp" do
      system "make", "install", *args
    end

    cd "php" do
        args << "install_phpdir=#{lib}/share/php"
        args << "install_libdir=#{lib}/php/extensions"
        system "make", "install", *args
    end
  end

  test do
    system "#{bin}/icebox", "--version"
  end

  def caveats
    <<-EOS.undent
      To enable IcePHP, you will need to change your php.ini
      to load the IcePHP extension. You can do this by adding
      IcePHP.dy to your list of extensions:

          extension=#{prefix}/php/IcePHP.dy

      Typical Ice PHP scripts will also expect to be able to 'require Ice.php'.

      You can ensure this is possible by appending the path to
      Ice's PHP includes to your global include_path in php.ini:

          include_path=<your-original-include-path>:#{prefix}/php

      However, you can also accomplish this on a script-by-script basis
      or via .htaccess if you so desire...
      EOS
  end
end

__END__
diff -r -c -N ../Ice-3.6b.orig/config/Make.common.rules ./config/Make.common.rules
*** ../Ice-3.6b.orig/config/Make.common.rules	2014-12-15 04:34:51.000000000 -0330
--- ./config/Make.common.rules	2015-02-10 15:34:26.000000000 -0330
***************
*** 1,6 ****
  # **********************************************************************
  #
! # Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
  #
  # This copy of Ice is licensed to you under the terms described in the
  # ICE_LICENSE file included in this distribution.
--- 1,6 ----
  # **********************************************************************
  #
! # Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
  #
  # This copy of Ice is licensed to you under the terms described in the
  # ICE_LICENSE file included in this distribution.
***************
*** 40,45 ****
--- 40,69 ----
  ice_bin_dist = 1
  endif

+ ifeq ($(UNAME),Darwin)
+     usr_dir = /usr/local
+ else
+     usr_dir = /usr
+ endif
+
+ #
+ # usr_dir_install means we want to install with a /usr style layout.
+ #
+ ifeq ($(prefix), /usr)
+     usr_dir_install = 1
+ endif
+
+ ifeq ($(prefix), /usr/local)
+     usr_dir_install = 1
+ endif
+
+ #
+ # A /usr style layout can be forced by setting USR_DIR_INSTALL=yes.
+ #
+ ifeq ($(USR_DIR_INSTALL),yes)
+     usr_dir_install = 1
+ endif
+
  ifeq ($(UNAME),SunOS)
      ifeq ($(MACHINE_TYPE),sun4u)
         lp64suffix	= /64
***************
*** 65,78 ****
        #
        # Ubuntu.
        #
!       ifeq ($(shell test -d /usr/lib/x86_64-linux-gnu && echo 0),0)
           lp64suffix	= /x86_64-linux-gnu
        endif

        #
        # Rhel/SLES
        #
!       ifeq ($(shell test -d /usr/lib64 && echo 0),0)
            lp64suffix	= 64
        endif

--- 89,102 ----
        #
        # Ubuntu.
        #
!       ifeq ($(shell test -d $(usr_dir)/lib/x86_64-linux-gnu && echo 0),0)
           lp64suffix	= /x86_64-linux-gnu
        endif

        #
        # Rhel/SLES
        #
!       ifeq ($(shell test -d $(usr_dir)/lib64 && echo 0),0)
            lp64suffix	= 64
        endif

***************
*** 85,91 ****
     endif
  endif

! ifeq ($(shell test -d /usr/lib/i386-linux-gnu && echo 0),0)
      lp32suffix     = /i386-linux-gnu
  endif

--- 109,115 ----
     endif
  endif

! ifeq ($(shell test -d $(usr_dir)/lib/i386-linux-gnu && echo 0),0)
      lp32suffix     = /i386-linux-gnu
  endif

***************
*** 119,128 ****
  	#
  	ifeq ($(MACHINE_TYPE),x86_64)
  		ifeq ($(UNAME),Linux)
! 			ifeq ($(shell test -d /usr/lib/x86_64-linux-gnu && echo 0),0)
! 				ifeq ($(ice_dir),/usr)
! 					lib64subdir               = lib/x86_64-linux-gnu
! 				endif
  			else
  				lib64subdir               = lib$(lp64suffix)
  			endif
--- 143,150 ----
  	#
  	ifeq ($(MACHINE_TYPE),x86_64)
  		ifeq ($(UNAME),Linux)
! 			ifeq ($(shell test -d $(usr_dir)/lib/x86_64-linux-gnu && echo 0),0)
! 				lib64subdir               = lib/x86_64-linux-gnu
  			else
  				lib64subdir               = lib$(lp64suffix)
  			endif
***************
*** 225,237 ****
          ifeq ($(shell test -f $(top_srcdir)/bin/$(slice_translator) && echo 0), 0)
              ice_dir = $(top_srcdir)
          else
! 	        ifeq ($(shell test -f /usr/bin/$(slice_translator) && echo 0), 0)
!                 ice_dir = /usr
                  ifeq ($(shell test -f /opt/Ice-$(VERSION)/bin/$(slice_translator) && echo 0), 0)
!                    $(warning Found $(slice_translator) in both /usr/bin and /opt/Ice-$(VERSION)/bin, /usr/bin/$(slice_translator) will be used!)
                  endif
                  ifeq ($(shell test -f /Library/Developer/Ice-$(VERSION)/bin/$(slice_translator) && echo 0), 0)
!                    $(warning Found $(slice_translator) in both /usr/bin and /Library/Developer/Ice-$(VERSION)/bin, /usr/bin/$(slice_translator) will be used!)
                  endif
              else
                  ifeq ($(shell test -f /Library/Developer/Ice-$(VERSION)/$(binsubdir)/$(slice_translator) && echo 0), 0)
--- 247,259 ----
          ifeq ($(shell test -f $(top_srcdir)/bin/$(slice_translator) && echo 0), 0)
              ice_dir = $(top_srcdir)
          else
! 	        ifeq ($(shell test -f $(usr_dir)/bin/$(slice_translator) && echo 0), 0)
!                 ice_dir = $(usr_dir)
                  ifeq ($(shell test -f /opt/Ice-$(VERSION)/bin/$(slice_translator) && echo 0), 0)
!                    $(warning Found $(slice_translator) in both $(usr_dir)/bin and /opt/Ice-$(VERSION)/bin, $(usr_dir)/bin/$(slice_translator) will be used!)
                  endif
                  ifeq ($(shell test -f /Library/Developer/Ice-$(VERSION)/bin/$(slice_translator) && echo 0), 0)
!                    $(warning Found $(slice_translator) in both $(usr_dir)/bin and /Library/Developer/Ice-$(VERSION)/bin, $(usr_dir)/bin/$(slice_translator) will be used!)
                  endif
              else
                  ifeq ($(shell test -f /Library/Developer/Ice-$(VERSION)/$(binsubdir)/$(slice_translator) && echo 0), 0)
***************
*** 269,297 ****
  #
  # Clear the embedded runpath prefix if building against RPM distribution.
  #
! ifeq ($(ice_dir), /usr)
      embedded_runpath_prefix =
  endif

  #
  # Set slicedir to the path of the directory containing the Slice files.
  #
! ifeq ($(ice_dir), /usr)
!     slicedir = /usr/share/Ice-$(VERSION)/slice
  else
      slicedir = $(ice_dir)/slice
  endif

! ifeq ($(prefix), /usr)
!     install_slicedir = /usr/share/Ice-$(VERSION)/slice
  else
      install_slicedir = $(prefix)/slice
  endif

  #
  # Set environment variables for the Slice translator.
  #
! ifneq ($(ice_dir), /usr)
      ifdef ice_src_dist
          ice_lib_dir = $(ice_cpp_dir)/$(libsubdir)
      else
--- 291,324 ----
  #
  # Clear the embedded runpath prefix if building against RPM distribution.
  #
! ifeq ($(ice_dir), $(usr_dir))
      embedded_runpath_prefix =
  endif

  #
  # Set slicedir to the path of the directory containing the Slice files.
  #
! ifeq ($(ice_dir), $(usr_dir))
!     slicedir = $(usr_dir)/share/slice
  else
      slicedir = $(ice_dir)/slice
  endif

! #
! # Installation location for slice and doc files.
! #
! ifdef usr_dir_install
!     install_slicedir = $(prefix)/share/Ice-$(VERSION)/slice
!     install_docdir = $(prefix)/share/Ice-$(VERSION)
  else
      install_slicedir = $(prefix)/slice
+     install_docdir = $(prefix)
  endif

  #
  # Set environment variables for the Slice translator.
  #
! ifneq ($(ice_dir), $(usr_dir))
      ifdef ice_src_dist
          ice_lib_dir = $(ice_cpp_dir)/$(libsubdir)
      else
***************
*** 425,440 ****
  endif

  install-common::
! 	@if test ! -d $(prefix) ; \
  	then \
  	    echo "Creating $(prefix)..." ; \
! 	    $(call mkdir,$(prefix), -p) ; \
  	fi

  	@if test ! -d $(DESTDIR)$(install_slicedir) ; \
  	then \
  	    echo "Creating $(DESTDIR)$(install_slicedir)..." ; \
  	    $(call mkdir, $(DESTDIR)$(install_slicedir), -p) ; \
  	    cd $(top_srcdir)/../slice ; \
  	    for subdir in * ; \
  	    do \
--- 452,471 ----
  endif

  install-common::
! 	@if test ! -d $(DESTDIR)$(prefix) ; \
  	then \
  	    echo "Creating $(prefix)..." ; \
! 	    $(call mkdir,$(DESTDIR)$(prefix), -p) ; \
  	fi

  	@if test ! -d $(DESTDIR)$(install_slicedir) ; \
  	then \
  	    echo "Creating $(DESTDIR)$(install_slicedir)..." ; \
  	    $(call mkdir, $(DESTDIR)$(install_slicedir), -p) ; \
+ 	    if test ! -z "$(usr_dir_install)" ; \
+ 	    then \
+ 		    ln -s Ice-$(VERSION)/slice $(DESTDIR)/$(prefix)/share/slice ; \
+ 	    fi ; \
  	    cd $(top_srcdir)/../slice ; \
  	    for subdir in * ; \
  	    do \
***************
*** 443,459 ****
  	    done ; \
  	    fi

! 	@if test ! -f $(DESTDIR)$(prefix)/ICE_LICENSE$(TEXT_EXTENSION) ; \
  	then \
! 	    $(call installdata,$(top_srcdir)/../ICE_LICENSE$(TEXT_EXTENSION),$(DESTDIR)$(prefix)) ; \
  	fi

! 	@if test ! -f $(DESTDIR)$(prefix)/LICENSE$(TEXT_EXTENSION) ; \
      then \
!         $(call installdata,$(top_srcdir)/../LICENSE$(TEXT_EXTENSION),$(DESTDIR)$(prefix)) ; \
      fi

! 	@if test ! -f $(DESTDIR)$(prefix)/CHANGES$(TEXT_EXTENSION) ; \
  	then \
! 		$(call installdata,$(top_srcdir)/../CHANGES$(TEXT_EXTENSION),$(DESTDIR)$(prefix)) ; \
  	fi
--- 474,490 ----
  	    done ; \
  	    fi

! 	@if test ! -f $(DESTDIR)$(install_docdir)/ICE_LICENSE$(TEXT_EXTENSION) ; \
  	then \
! 	    $(call installdata,$(top_srcdir)/../ICE_LICENSE$(TEXT_EXTENSION),$(DESTDIR)$(install_docdir)) ; \
  	fi

! 	@if test ! -f $(DESTDIR)$(install_docdir)/LICENSE$(TEXT_EXTENSION) ; \
      then \
!         $(call installdata,$(top_srcdir)/../LICENSE$(TEXT_EXTENSION),$(DESTDIR)$(install_docdir)) ; \
      fi

! 	@if test ! -f $(DESTDIR)$(install_docdir)/CHANGES$(TEXT_EXTENSION) ; \
  	then \
! 		$(call installdata,$(top_srcdir)/../CHANGES$(TEXT_EXTENSION),$(DESTDIR)$(install_docdir)) ; \
  	fi
diff -r -c -N ../Ice-3.6b.orig/cpp/config/Make.rules ./cpp/config/Make.rules
*** ../Ice-3.6b.orig/cpp/config/Make.rules	2014-12-15 04:34:53.000000000 -0330
--- ./cpp/config/Make.rules	2015-02-10 15:34:37.000000000 -0330
***************
*** 199,212 ****
  include	 $(top_srcdir)/config/Make.rules.$(UNAME)

  install_includedir	:= $(prefix)/include
- install_docdir		:= $(prefix)/doc
  install_bindir	  	:= $(prefix)/$(binsubdir)$(cpp11suffix)
  install_libdir	  	:= $(prefix)/$(libsubdir)$(cpp11suffix)
- install_configdir 	:= $(prefix)/config

! ifneq ($(prefix),/usr)
  install_mandir		:= $(prefix)/man/man1
  else
  install_mandir		:= $(prefix)/share/man/man1
  endif

--- 199,212 ----
  include	 $(top_srcdir)/config/Make.rules.$(UNAME)

  install_includedir	:= $(prefix)/include
  install_bindir	  	:= $(prefix)/$(binsubdir)$(cpp11suffix)
  install_libdir	  	:= $(prefix)/$(libsubdir)$(cpp11suffix)

! ifndef usr_dir_install
  install_mandir		:= $(prefix)/man/man1
+ install_configdir 	:= $(prefix)/config
  else
+ install_configdir 	:= $(prefix)/share/config
  install_mandir		:= $(prefix)/share/man/man1
  endif

***************
*** 284,290 ****

  SLICE2CPPFLAGS		= $(ICECPPFLAGS)

! ifeq ($(ice_dir), /usr)
  	LDFLAGS		= $(LDPLATFORMFLAGS) $(CXXFLAGS)
  	ifeq ($(CPP11),yes)
              LDFLAGS = $(LDPLATFORMFLAGS) $(CXXFLAGS) -L$(ice_dir)/$(libsubdir)$(cpp11libdirsuffix)
--- 284,290 ----

  SLICE2CPPFLAGS		= $(ICECPPFLAGS)

! ifeq ($(ice_dir), $(usr_dir))
  	LDFLAGS		= $(LDPLATFORMFLAGS) $(CXXFLAGS)
  	ifeq ($(CPP11),yes)
              LDFLAGS = $(LDPLATFORMFLAGS) $(CXXFLAGS) -L$(ice_dir)/$(libsubdir)$(cpp11libdirsuffix)
diff -r -c -N ../Ice-3.6b.orig/cpp/config/Make.rules.Darwin ./cpp/config/Make.rules.Darwin
*** ../Ice-3.6b.orig/cpp/config/Make.rules.Darwin	2014-12-15 04:34:51.000000000 -0330
--- ./cpp/config/Make.rules.Darwin	2015-02-10 15:34:26.000000000 -0330
***************
*** 69,75 ****
      #
      # Clear rpath setting when doing a system install
      #
!     ifeq ($(ice_dir),/usr)
          RPATH_DIR =
      endif

--- 69,75 ----
      #
      # Clear rpath setting when doing a system install
      #
!     ifeq ($(ice_dir), $(usr_dir))
          RPATH_DIR =
      endif

diff -r -c -N ../Ice-3.6b.orig/cpp/config/Make.rules.Linux ./cpp/config/Make.rules.Linux
*** ../Ice-3.6b.orig/cpp/config/Make.rules.Linux	2014-12-15 04:34:51.000000000 -0330
--- ./cpp/config/Make.rules.Linux	2015-02-10 15:34:26.000000000 -0330
***************
*** 112,118 ****
          #
          # Clear the rpath dir when doing a system install.
          #
!         ifeq ($(ice_dir), /usr)
              RPATH_DIR =
          endif

--- 112,118 ----
          #
          # Clear the rpath dir when doing a system install.
          #
!         ifeq ($(ice_dir), $(usr_dir))
              RPATH_DIR =
          endif

diff -r -c -N ../Ice-3.6b.orig/cpp/src/Glacier2/Makefile ./cpp/src/Glacier2/Makefile
*** ../Ice-3.6b.orig/cpp/src/Glacier2/Makefile	2014-12-15 04:34:52.000000000 -0330
--- ./cpp/src/Glacier2/Makefile	2015-02-10 15:34:27.000000000 -0330
***************
*** 33,44 ****

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I.. $(CPPFLAGS) $(OPENSSL_FLAGS)
  SLICE2CPPFLAGS	:= --include-dir Glacier2 $(SLICE2CPPFLAGS)

  $(ROUTER): $(OBJS)
  	rm -f $@
! 	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(OBJS) -lGlacier2 $(LIBS) -lIceSSL $(OPENSSL_LIBS)

  install:: all
  	$(call installprogram,$(ROUTER),$(DESTDIR)$(install_bindir))
--- 33,44 ----

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I.. $(CPPFLAGS)
  SLICE2CPPFLAGS	:= --include-dir Glacier2 $(SLICE2CPPFLAGS)

  $(ROUTER): $(OBJS)
  	rm -f $@
! 	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(OBJS) -lGlacier2 $(LIBS) -lIceSSL $(OPENSSL_RPATH_LINK)

  install:: all
  	$(call installprogram,$(ROUTER),$(DESTDIR)$(install_bindir))
diff -r -c -N ../Ice-3.6b.orig/cpp/src/IceGrid/Makefile ./cpp/src/IceGrid/Makefile
*** ../Ice-3.6b.orig/cpp/src/IceGrid/Makefile	2014-12-15 04:34:53.000000000 -0330
--- ./cpp/src/IceGrid/Makefile	2015-02-10 15:34:37.000000000 -0330
***************
*** 100,106 ****

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= $(CPPFLAGS) -I.. $(OPENSSL_FLAGS) $(READLINE_FLAGS)
  ICECPPFLAGS	:= $(ICECPPFLAGS) -I..
  SLICE2CPPFLAGS 	:= --checksum --ice --include-dir IceGrid $(SLICE2CPPFLAGS)
  SLICE2FREEZECMD	:= $(SLICE2FREEZE) --ice --include-dir IceGrid $(ICECPPFLAGS)
--- 100,106 ----

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= $(CPPFLAGS) -I.. $(READLINE_FLAGS)
  ICECPPFLAGS	:= $(ICECPPFLAGS) -I..
  SLICE2CPPFLAGS 	:= --checksum --ice --include-dir IceGrid $(SLICE2CPPFLAGS)
  SLICE2FREEZECMD	:= $(SLICE2FREEZE) --ice --include-dir IceGrid $(ICECPPFLAGS)
***************
*** 113,124 ****
  $(REGISTRY_SERVER): $(REGISTRY_SVR_OBJS) $(LIBTARGETS)
  	rm -f $@
  	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(REGISTRY_SVR_OBJS) -lIceGrid -lIceStorm -lIceStormService -lGlacier2 -lIcePatch2 \
! 	-lFreeze -lIceBox $(EXPAT_RPATH_LINK) -lIceXML -lIceSSL $(OPENSSL_LIBS) $(LIBS)

  $(NODE_SERVER): $(NODE_SVR_OBJS) $(LIBTARGETS)
  	rm -f $@
  	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(NODE_SVR_OBJS) -lIceGrid -lIceStorm -lIceStormService -lIceBox -lGlacier2 \
! 	-lFreeze -lIcePatch2 $(EXPAT_RPATH_LINK) -lIceXML -lIceSSL $(OPENSSL_LIBS) $(LIBS)

  # The slice2freeze rules are structured like this to avoid issues with
  # parallel make.
--- 113,124 ----
  $(REGISTRY_SERVER): $(REGISTRY_SVR_OBJS) $(LIBTARGETS)
  	rm -f $@
  	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(REGISTRY_SVR_OBJS) -lIceGrid -lIceStorm -lIceStormService -lGlacier2 -lIcePatch2 \
! 	-lFreeze -lIceBox $(EXPAT_RPATH_LINK) -lIceXML -lIceSSL $(OPENSSL_RPATH_LINK) $(LIBS)

  $(NODE_SERVER): $(NODE_SVR_OBJS) $(LIBTARGETS)
  	rm -f $@
  	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(NODE_SVR_OBJS) -lIceGrid -lIceStorm -lIceStormService -lIceBox -lGlacier2 \
! 	-lFreeze -lIcePatch2 $(EXPAT_RPATH_LINK) -lIceXML -lIceSSL $(OPENSSL_RPATH_LINK) $(LIBS)

  # The slice2freeze rules are structured like this to avoid issues with
  # parallel make.
diff -r -c -N ../Ice-3.6b.orig/cpp/src/IcePatch2/Makefile ./cpp/src/IcePatch2/Makefile
*** ../Ice-3.6b.orig/cpp/src/IcePatch2/Makefile	2014-12-15 04:34:52.000000000 -0330
--- ./cpp/src/IcePatch2/Makefile	2015-02-10 15:34:27.000000000 -0330
***************
*** 30,36 ****

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I. -I.. $(CPPFLAGS) $(OPENSSL_FLAGS) $(BZIP2_FLAGS)

  $(SERVER): $(SOBJS) $(LIBTARGETS)
  	rm -f $@
--- 30,36 ----

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I. -I.. $(CPPFLAGS) $(BZIP2_FLAGS)

  $(SERVER): $(SOBJS) $(LIBTARGETS)
  	rm -f $@
diff -r -c -N ../Ice-3.6b.orig/cpp/src/IcePatch2Lib/Makefile ./cpp/src/IcePatch2Lib/Makefile
*** ../Ice-3.6b.orig/cpp/src/IcePatch2Lib/Makefile	2014-12-15 04:34:52.000000000 -0330
--- ./cpp/src/IcePatch2Lib/Makefile	2015-02-10 15:34:27.000000000 -0330
***************
*** 27,35 ****

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I. -I.. $(CPPFLAGS) $(OPENSSL_FLAGS) $(BZIP2_FLAGS)
  SLICE2CPPFLAGS	:= --ice --include-dir IcePatch2 --dll-export ICE_PATCH2_API $(SLICE2CPPFLAGS)
! LINKWITH	:= $(BZIP2_RPATH_LINK) -lIce -lIceUtil $(OPENSSL_LIBS) $(BZIP2_LIBS)

  $(libdir)/$(LIBFILENAME): $(OBJS)
  	@mkdir -p $(dir $@)
--- 27,35 ----

  include $(top_srcdir)/config/Make.rules

! CPPFLAGS	:= -I. -I.. $(CPPFLAGS) $(BZIP2_FLAGS)
  SLICE2CPPFLAGS	:= --ice --include-dir IcePatch2 --dll-export ICE_PATCH2_API $(SLICE2CPPFLAGS)
! LINKWITH	:= $(BZIP2_RPATH_LINK) -lIce -lIceUtil $(BZIP2_LIBS)

  $(libdir)/$(LIBFILENAME): $(OBJS)
  	@mkdir -p $(dir $@)
diff -r -c -N ../Ice-3.6b.orig/cs/config/Make.rules.cs ./cs/config/Make.rules.cs
*** ../Ice-3.6b.orig/cs/config/Make.rules.cs	2014-12-15 04:34:52.000000000 -0330
--- ./cs/config/Make.rules.cs	2015-02-10 15:34:29.000000000 -0330
***************
*** 89,95 ****

  install_libdir		    = $(prefix)/lib

! ifneq ($(prefix),/usr)
  install_mandir		:= $(prefix)/man/man1
  else
  install_mandir		:= $(prefix)/share/man/man1
--- 89,95 ----

  install_libdir		    = $(prefix)/lib

! ifndef usr_dir_install
  install_mandir		:= $(prefix)/man/man1
  else
  install_mandir		:= $(prefix)/share/man/man1
***************
*** 97,103 ****

  install_pkgconfigdir    = $(prefix)/lib/pkgconfig

! ifeq ($(ice_dir),/usr)
      ref = -pkg:$(1)
  else
      ifdef ice_src_dist
--- 97,103 ----

  install_pkgconfigdir    = $(prefix)/lib/pkgconfig

! ifeq ($(ice_dir), $(usr_dir))
      ref = -pkg:$(1)
  else
      ifdef ice_src_dist
diff -r -c -N ../Ice-3.6b.orig/php/config/Make.rules.php ./php/config/Make.rules.php
*** ../Ice-3.6b.orig/php/config/Make.rules.php	2014-12-15 04:34:52.000000000 -0330
--- ./php/config/Make.rules.php	2015-02-10 15:34:34.000000000 -0330
***************
*** 107,113 ****
  endif

  libdir			= $(top_srcdir)/lib
! ifneq ($(prefix), /usr)
  install_phpdir      = $(prefix)/php
  install_libdir      = $(prefix)/php
  else
--- 107,114 ----
  endif

  libdir			= $(top_srcdir)/lib
!
! ifndef usr_dir_install
  install_phpdir      = $(prefix)/php
  install_libdir      = $(prefix)/php
  else
diff -r -c -N ../Ice-3.6b.orig/py/config/Make.rules ./py/config/Make.rules
*** ../Ice-3.6b.orig/py/config/Make.rules	2014-12-15 04:34:52.000000000 -0330
--- ./py/config/Make.rules	2015-02-10 15:34:35.000000000 -0330
***************
*** 47,65 ****

  #
  # If multiple versions of Python are installed and you want a specific
! # version used for building the Ice extension, then set PYTHON_VERSION
! # to a value like "python2.5". Otherwise, the settings below use the
! # default Python interpreter found in your PATH.
  #
! PYTHON_VERSION	    ?= python$(shell python -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_version())")

! PYTHON_BASE_VERSION ?= $(shell $(PYTHON_VERSION) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_version())")

! PYTHON_INCLUDE_DIR  ?= $(shell $(PYTHON_VERSION) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_inc())")

! PYTHON_LIB_DIR	    ?= $(shell $(PYTHON_VERSION) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_config_var('LIBPL'))")

! PYTHON_LIB_SUFFIX   ?= $(shell $(PYTHON_VERSION) -c "import sys; sys.stdout.write(sys.__dict__['abiflags'] if 'abiflags' in sys.__dict__ else '')")

  PYTHON_LIB_NAME	    ?= $(PYTHON_VERSION)$(PYTHON_LIB_SUFFIX)

--- 47,66 ----

  #
  # If multiple versions of Python are installed and you want a specific
! # version used for building the Ice extension, then set PYTHON to
! # the specific to the location of the python interpreter.
  #
! PYTHON              ?= python

! PYTHON_VERSION      ?= python$(shell $(PYTHON) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_version())")

! PYTHON_BASE_VERSION ?= $(shell $(PYTHON) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_version())")

! PYTHON_INCLUDE_DIR  ?= $(shell $(PYTHON) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_python_inc())")

! PYTHON_LIB_DIR	    ?= $(shell $(PYTHON) -c "import sys; import distutils.sysconfig as ds; sys.stdout.write(ds.get_config_var('LIBPL'))")
!
! PYTHON_LIB_SUFFIX   ?= $(shell $(PYTHON) -c "import sys; sys.stdout.write(sys.__dict__['abiflags'] if 'abiflags' in sys.__dict__ else '')")

  PYTHON_LIB_NAME	    ?= $(PYTHON_VERSION)$(PYTHON_LIB_SUFFIX)

***************
*** 92,98 ****
  	include $(top_srcdir)/../config/Make.common.rules
  endif

! ifneq ($(prefix),/usr)
  RPATH_DIR	= $(prefix)/$(libsubdir)
  endif

--- 93,99 ----
  	include $(top_srcdir)/../config/Make.common.rules
  endif

! ifndef usr_dir_install
  RPATH_DIR	= $(prefix)/$(libsubdir)
  endif

***************
*** 106,134 ****
  endif

  libdir                  = $(top_srcdir)/python
! ifneq ($(prefix), /usr)
      install_pythondir		= $(prefix)/python
      install_libdir			= $(prefix)/python
  else
!     ifeq ($(shell test -d $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/dist-packages && echo 0),0)
!         install_pythondir	= $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/dist-packages
!         install_libdir		= $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/dist-packages
!     endif
!
!     ifeq ($(shell test -d $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/site-packages && echo 0),0)
!         install_pythondir	= $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/site-packages
!         install_libdir		= $(prefix)/$(libsubdir)/$(PYTHON_VERSION)/site-packages
!     endif
!
!     ifeq ($(shell test -d $(prefix)/lib/$(PYTHON_VERSION)/dist-packages && echo 0),0)
!         install_pythondir	= $(prefix)/lib/$(PYTHON_VERSION)/dist-packages
!         install_libdir		= $(prefix)/lib/$(PYTHON_VERSION)/dist-packages
!     endif
!
!     ifeq ($(shell test -d $(prefix)/lib/$(PYTHON_VERSION)/site-packages && echo 0),0)
!         install_pythondir	= $(prefix)/lib/$(PYTHON_VERSION)/site-packages
!         install_libdir		= $(prefix)/lib/$(PYTHON_VERSION)/site-packages
!     endif
  endif

  ifeq ($(UNAME),SunOS)
--- 107,123 ----
  endif

  libdir                  = $(top_srcdir)/python
!
! ifndef usr_dir_install
      install_pythondir		= $(prefix)/python
      install_libdir			= $(prefix)/python
  else
!     #
!     # The install_dir script says where python wants site-packages installed.
!     #
!
!     install_pythondir = $(shell $(PYTHON) $(top_srcdir)/config/install_dir)
!     install_libdir = $(install_pythondir)
  endif

  ifeq ($(UNAME),SunOS)
diff -r -c -N ../Ice-3.6b.orig/rb/config/Make.rules ./rb/config/Make.rules
*** ../Ice-3.6b.orig/rb/config/Make.rules	2014-12-15 04:34:53.000000000 -0330
--- ./rb/config/Make.rules	2015-02-10 15:34:36.000000000 -0330
***************
*** 144,150 ****
  install_libdir		= $(prefix)/ruby
  endif
  else
! ifneq ($(prefix), /usr)
  install_rubydir		= $(prefix)/ruby
  install_libdir		= $(prefix)/ruby
  else
--- 144,150 ----
  install_libdir		= $(prefix)/ruby
  endif
  else
! ifndef usr_dir_install
  install_rubydir		= $(prefix)/ruby
  install_libdir		= $(prefix)/ruby
  else
***************
*** 152,157 ****
--- 152,158 ----
  install_libdir		= $(RUBY_LIB_DIR)/$(RUBY_ARCH)
  endif
  endif
+
  install_bindir		= $(prefix)/$(binsubdir)

  #
***************
*** 163,169 ****
  	configdir = $(top_srcdir)/../cpp/config
  endif

! ifneq ($(prefix),/usr)
  RPATH_DIR   = $(prefix)/$(libsubdir)
  endif

--- 164,170 ----
  	configdir = $(top_srcdir)/../cpp/config
  endif

! ifndef usr_dir_install
  RPATH_DIR   = $(prefix)/$(libsubdir)
  endif

