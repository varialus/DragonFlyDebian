# Build optimized library packages

cpu_flags = $(cpu_flags_$(OPT))
as_flags = $(as_flags_$(OPT))
objdir_opt = $(objdir)_$(OPT)
install_root_opt = $(install_root)_$(OPT)
stamp_install_opt = $(stamp_install)_$(OPT)
stamp_build_opt = $(stamp_build)_$(OPT)
stamp_configure_opt = $(stamp_configure)_$(OPT)

# This is the same thing glibc does with --enable-omitfp
opt_flags = -g0 -O99 -fomit-frame-pointer -D__USE_STRING_INLINES -Wall $(as_flags) $(cpu_flags)

ifeq ($(log_build),/dev/tty)
  log_build_opt = /dev/tty
else
  log_build_opt = $(log_build)_$(OPT)
endif

$(stamp_install_opt): $(stamp_build_opt)
	$(checkroot)
	$(make_directory) $(install_root_opt)
	$(MAKE) -C $(objdir_opt) install_root=$(install_root_opt) install
	touch $@

$(libc)-$(OPT)-build: $(stamp_build_opt)
$(stamp_build_opt): $(stamp_configure_opt)
ifeq ($(NO_LOG),)
	@if [ -s $(log_build_opt) ]; then savelog $(log_build_opt); fi
endif
	@echo 'Building GNU C Library for a $(DEB_BUILD_GNU_TYPE) host ($(OPT) Optimized).'
	$(MAKE) -C $(objdir_opt) PARALLELMFLAGS="$(PARALLELMFLAGS)" 2>&1 | tee $(log_build_opt)
	touch $@

$(stamp_configure_opt): $(stamp_unpack) $(stamp_patch)
	$(make_directory) $(objdir_opt) $(stampdir)
	rm -f $(objdir_opt)/configparms
	echo "CC = $(CC)"		>> $(objdir_opt)/configparms
	echo "BUILD_CC = $(BUILD_CC)"	>> $(objdir_opt)/configparms
	echo "CFLAGS = $(opt_flags)"	>> $(objdir_opt)/configparms
	echo "BUILD_CFLAGS = $(opt_flags)"	>> $(objdir_opt)/configparms
	echo "BASH := /bin/bash"	>> $(objdir_opt)/configparms
	echo "KSH := /bin/bash"		>> $(objdir_opt)/configparms
	echo "mandir = $(mandir)"	>> $(objdir_opt)/configparms
	echo "infodir = $(infodir)"	>> $(objdir_opt)/configparms
	echo "libexecdir = $(libexecdir)"	>> $(objdir_opt)/configparms
	echo "LIBGD = no"		>> $(objdir_opt)/configparms
	echo "ASFLAGS-.os = $(as_flags)"	>> $(objdir_opt)/configparms
	echo 
	cd $(objdir_opt) && CC="$(CC)" CFLAGS="$(opt_flags)" \
		$(srcdir)/configure --host=$(DEB_HOST_GNU_TYPE) \
		--build=$(DEB_BUILD_GNU_TYPE) --prefix=/usr --without-cvs \
		--disable-profile --enable-kernel=2.4.1 \
		--enable-add-ons="$(add-ons)" $(with_headers)

	touch $@

$(libc)-$(OPT): $(stamp_install_opt) debian/control $(mkdir)/sysdeps.mk \
  debian/libc/DEBIAN/shlibs
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(INSTALL_PROGRAM) debian/libc-opt/p* $(tmpdir)/$@/DEBIAN
	# blah, not the m4's, process them
	rm $(tmpdir)/$@/DEBIAN/*.m4
	for m4 in debian/libc-opt/*.m4; do \
		bn=`basename $$m4 .m4`; \
		m4 -DOPT=$(OPT) $$m4 > \
			$(tmpdir)/$@/DEBIAN/$$bn; \
		chmod 755 $(tmpdir)/$@/DEBIAN/$$bn; \
	done
	$(INSTALL_DATA) debian/libc/DEBIAN/shlibs $(tmpdir)/$@/DEBIAN

	$(make_directory) $(tmpdir)/$@/lib/$(OPT)
	$(INSTALL_DATA) $(install_root_opt)/lib/lib*-$(VERSION).so $(tmpdir)/$@/lib/$(OPT)/.
	$(INSTALL_PROGRAM) $(install_root_opt)/lib/libc-$(VERSION).so $(tmpdir)/$@/lib/$(OPT)/.
	$(INSTALL_DATA) $(install_root_opt)/lib/libSegFault.so $(tmpdir)/$@/lib/$(OPT)/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(install_root_opt)/lib/libpthread-0.10.so $(tmpdir)/$@/lib/$(OPT)/.
	$(INSTALL_DATA) $(install_root_opt)/lib/libthread_db-1.0.so $(tmpdir)/$@/lib/$(OPT)/.
endif
	@set -e; \
	cd $(install_root_opt)/lib; \
	for l in `find . -type l -name 'lib*.so.*'`; \
	do cp -vdf $$l $(tmpdir)/$@/lib/$(OPT)/.; done
	cd $(tmpdir)/$@ && \
	$(STRIP) lib/$(OPT)/lib*-$(VERSION).so
ifeq ($(threads),yes)
	$(STRIP) $(tmpdir)/$@/lib/$(OPT)/libpthread-0.10.so
	$(STRIP) $(tmpdir)/$@/lib/$(OPT)/libthread_db-1.0.so
endif
	# Get rid of the NSS libs, they don't get used anyway
	rm -f $(tmpdir)/$@/lib/$(OPT)/libnss_*
	# Yes, we need ld-linux.so, it is most important
	$(INSTALL_PROGRAM) $(install_root_opt)/lib/ld*.so.* $(tmpdir)/$@/lib/.
	$(make_directory) $(tmpdir)/$@$(docdir)
	ln -sf $(libc) $(tmpdir)/$@$(docdir)/$@
	# The libsafe and memprof packages do not like our opt packages
	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@ -DDepends="$(libc) (= $(DEBVERSION))" \
		$(libc_opt_control_flags)
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..

opt-$(libc)-%-build:
	$(MAKE) -f debian/rules OPT=$* $(libc)-$*-build

opt-$(libc)-%-pkg:
	$(MAKE) -f debian/rules OPT=$* $(libc)-$*
