$(libc): $(stamp_install) debian/control $(mkdir)/sysdeps.mk debian/libc/DEBIAN/shlibs
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/lib
	$(INSTALL_PROGRAM) $(install_root)/lib/ld-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/lib*-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_PROGRAM) $(install_root)/lib/libc-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/libSegFault.so $(tmpdir)/$@/lib/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(install_root)/lib/libpthread-0.10.so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/libthread_db-1.0.so $(tmpdir)/$@/lib/.
endif
	@set -ex; cd $(install_root)/lib && \
	for l in `find . -type l -name '*.so.*' ! -name 'libnss*_*.so.1*'`; \
	do cp -df $(install_root)/lib/$$l $(tmpdir)/$@/lib/.; done
ifeq ($(DEB_HOST_GNU_SYSTEM),gnu)
# Why doesn't the glibc makefile install this?
	ln -sf ld.so.1 $(tmpdir)/$@/lib/ld.so
endif
	$(make_directory) $(tmpdir)/$@$(libdir)/gconv
	$(INSTALL_DATA) $(install_root)$(libdir)/gconv/* $(tmpdir)/$@$(libdir)/gconv/.

	$(make_directory) $(tmpdir)/$@$(datadir)
	$(make_directory) $(tmpdir)/$@$(bindir)
	$(INSTALL_PROGRAM) $(addprefix $(install_root)$(bindir)/, \
		iconv locale localedef getent) $(tmpdir)/$@$(bindir)/.
	$(INSTALL_SCRIPT) $(addprefix $(install_root)$(bindir)/, \
		catchsegv glibcbug tzselect) $(tmpdir)/$@$(bindir)/.
	$(INSTALL_SCRIPT) $(install_root)$(bindir)/ldd $(tmpdir)/$@$(bindir)/.
	set -e ; if [ -f "$(install_root)$(bindir)/lddlibc4" ] ; then \
		$(INSTALL_PROGRAM) $(install_root)$(bindir)/lddlibc4 $(tmpdir)/$@$(bindir)/.; \
	fi
	$(make_directory) $(tmpdir)/$@/sbin
ifeq ($(DEB_HOST_GNU_SYSTEM),gnu)
	# Fake ldconfig script for HURD
	$(INSTALL_SCRIPT) debian/ldconfig-hurd.sh $(tmpdir)/$@/sbin/ldconfig
else
	$(INSTALL_PROGRAM) $(install_root)/sbin/ldconfig $(tmpdir)/$@/sbin
endif
	$(make_directory) $(tmpdir)/$@$(sbindir)
	$(INSTALL_PROGRAM) $(addprefix $(install_root)$(sbindir)/, \
		zic iconvconfig) $(tmpdir)/$@$(sbindir)/.

	# History wants rpcinfo and zdump here
	$(INSTALL_PROGRAM) $(addprefix $(install_root)$(sbindir)/, \
		zdump rpcinfo) $(tmpdir)/$@$(bindir)/.

	$(make_directory) $(tmpdir)/$@$(libexecdir)
	$(INSTALL) --mode=4755 $(install_root)$(libexecdir)/pt_chown $(tmpdir)/$@$(libexecdir)/.

	$(make_directory) $(tmpdir)/$@$(mandir)/man1
	$(INSTALL_DATA) $(addprefix debian/manpages/, \
		getent.1 iconv.1 locale.1 localedef.1 tzselect.1 ldd.1 zdump.1 catchsegv.1 glibcbug.1) \
		$(tmpdir)/$@$(mandir)/man1/.

	$(make_directory) $(tmpdir)/$@$(mandir)/man8
	$(INSTALL_DATA) $(addprefix debian/manpages/, \
		zic.8 ld.so.8 ldconfig.8 rpcinfo.8) $(tmpdir)/$@$(mandir)/man8/.

	-gzip -9f $(tmpdir)/$@$(mandir)/man?/*

# It is safe to strip the dynamic linker though _dl_debug_state must be kept
# in order for gdb to work.
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
  #ifeq ($(DEB_HOST_GNU_CPU),i386) // Let's try this for all archs
	$(STRIP) -g -K _dl_debug_state -R .note -R .comment $(tmpdir)/$@/lib/ld-$(VERSION).so
  #endif
	cd $(tmpdir)/$@ && \
	$(STRIP) --strip-unneeded -R .note -R .comment lib/libSegFault.so \
	lib/lib*-$(VERSION).so ./$(libexecdir)/pt_chown
	-$(STRIP) --strip-unneeded -R .note $(tmpdir)/$@$(bindir)/* $(tmpdir)/$@$(sbindir)/* \
		$(tmpdir)/$@/sbin/*
ifeq ($(threads),yes)
	$(STRIP) --strip-debug -R .note -R .comment $(tmpdir)/$@/lib/libpthread-0.10.so
	$(STRIP) --strip-unneeded -R .note -R .comment $(tmpdir)/$@/lib/libthread_db-1.0.so
endif
	$(STRIP) $(tmpdir)/$@$(libdir)/gconv/*.so
endif
	$(make_directory) $(tmpdir)/$@$(datadir)
ifeq ($(cross_compiling),yes)
	$(warning Copying zoneinfo from build system.)
	cp -a /usr/share/zoneinfo $(tmpdir)/$@$(datadir)/.
else
	cp -a $(install_root)$(datadir)/zoneinfo $(tmpdir)/$@$(datadir)/.
endif
	ln -sf /etc/localtime $(tmpdir)/$@$(datadir)/zoneinfo/localtime
	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) $(addprefix $(srcdir)/,BUGS FAQ INSTALL INTERFACE \
	NEWS NOTES PROJECTS README hesiod/README.hesiod) \
	$(tmpdir)/$@$(docdir)/$@/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(srcdir)/linuxthreads/ChangeLog \
		$(tmpdir)/$@$(docdir)/$@/ChangeLog.linuxthreads
	$(INSTALL_DATA) $(srcdir)/linuxthreads/README $(tmpdir)/$@$(docdir)/$@/README.linuxthreads
endif
	$(INSTALL_DATA) debian/FAQ $(tmpdir)/$@$(docdir)/$@/README.Debian
	$(INSTALL_DATA) $(srcdir)/ChangeLog $(tmpdir)/$@$(docdir)/$@/changelog
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/copyright

	cp -a debian/$@/* $(tmpdir)/$@

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@ $(libc_control_flags) \
		-DProvides="$(shell perl debian/debver2localesdep.pl $(DEBVERSION))"
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
