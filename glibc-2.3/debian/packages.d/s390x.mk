# Build 64bit libraries

objdir_64		= $(objdir)_64
install_root_64		= $(install_root)_64
stamp_install_64	= $(stamp_install)_64
stamp_build_64		= $(stamp_build)_64
stamp_configure_64	= $(stamp_configure)_64

flags_64 = -g0 -O2 -Wall

MYCC = gcc-3.2 -m64

ifeq ($(log_build),/dev/tty)
  log_build_64 = /dev/tty
else
  log_build_64 = $(log_build)_64
endif

$(stamp_install_64): $(stamp_build_64)
	$(checkroot)
	$(make_directory) $(install_root_64)
	$(MAKE) -C $(objdir_64) install_root=$(install_root_64) install
	touch $@

$(stamp_build_64): $(stamp_configure_64)
ifeq ($(NO_LOG),)
	@if [ -s $(log_build_64) ]; then savelog $(log_build_64); fi
endif
	@echo 'Building GNU C Library for a $(DEB_BUILD_GNU_TYPE) host (64bit).'
	$(MAKE) -C $(objdir_64) PARALLELMFLAGS="$(PARALLELMFLAGS)" 2>&1 | tee $(log_build_64)
	touch $@

$(stamp_configure_64): $(stamp_unpack) $(stamp_patch)
	$(make_directory) $(objdir_64) $(stampdir)
	rm -f $(objdir_64)/configparms
	echo "CC = $(MYCC)"		>> $(objdir_64)/configparms
	echo "BUILD_CC = $(MYCC)"	>> $(objdir_64)/configparms
	echo "CFLAGS = $(flags_64)"	>> $(objdir_64)/configparms
	echo "BUILD_CFLAGS = $(flags_64)"	>> $(objdir_64)/configparms
	echo "BASH := /bin/bash"	>> $(objdir_64)/configparms
	echo "KSH := /bin/bash"		>> $(objdir_64)/configparms
	echo "mandir = $(mandir)"	>> $(objdir_64)/configparms
	echo "infodir = $(infodir)"	>> $(objdir_64)/configparms
	echo "libexecdir = $(libexecdir)"	>> $(objdir_64)/configparms
	echo "LIBGD = no"		>> $(objdir_64)/configparms
	echo "cross-compiling = yes"	>> $(objdir_64)/configparms
	echo 
	cd $(objdir_64) && CC="$(MYCC)" CFLAGS="$(flags_64)" \
	$(srcdir)/configure --host=s390x-linux \
		--build=s390-linux --prefix=/usr --without-cvs \
		--disable-profile --enable-static --enable-kernel=2.4.0 \
		--enable-add-ons="$(add-ons)" $(with_headers)

	touch $@

$(libc)-s390x: $(stamp_install_64) debian/control $(mkdir)/sysdeps.mk \
  debian/libc/DEBIAN/shlibs
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(INSTALL_PROGRAM) debian/libc-s390x/p* $(tmpdir)/$@/DEBIAN
	cat debian/libc/DEBIAN/shlibs | sed -e 's_$(libc)_$@_' -e \
		's_/lib/_/lib64/_' > \
		$(tmpdir)/$@/DEBIAN/shlibs

	$(make_directory) $(tmpdir)/$@/lib64 $(tmpdir)/$@/usr/lib64

	# Compatibility links
	$(make_directory) $(tmpdir)/$@/lib $(tmpdir)/$@/usr/lib
	ln -s ../lib64 $(tmpdir)/$@/lib/64
	ln -s ../lib64 $(tmpdir)/$@/usr/lib/64

	$(INSTALL_DATA) $(install_root_64)/lib64/lib*-$(VERSION).so $(tmpdir)/$@/lib64/.
	$(INSTALL_PROGRAM) $(install_root_64)/lib64/libc-$(VERSION).so $(tmpdir)/$@/lib64/.
	$(INSTALL_DATA) $(install_root_64)/lib64/libSegFault.so $(tmpdir)/$@/lib64/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(install_root_64)/lib64/libpthread-0.10.so $(tmpdir)/$@/lib64/.
	$(INSTALL_DATA) $(install_root_64)/lib64/libthread_db-1.0.so $(tmpdir)/$@/lib64/.
endif
	@set -e; \
	cd $(install_root_64)/lib64/; \
	for l in `find . -type l -name 'lib*.so.*'`; \
		do cp -vdf $$l $(tmpdir)/$@/lib64/.; done
	cd $(tmpdir)/$@ && \
	$(STRIP) lib64/lib*-$(VERSION).so
ifeq ($(threads),yes)
	$(STRIP) $(tmpdir)/$@/lib64/libpthread-0.10.so
	$(STRIP) $(tmpdir)/$@/lib64/libthread_db-1.0.so
endif
	$(INSTALL_PROGRAM) $(install_root_64)/lib64/ld-$(VERSION).so \
		$(tmpdir)/$@/lib64/.
	#### XXX
	# test -e /lib64/ld-linux.so.2 && \
		# $(INSTALL_PROGRAM) /lib64/ld-*.so $(tmpdir)/$@/lib64/ld-$(VERSION).so
	cp -vdf $(install_root_64)/lib64/ld*.so.* \
		$(tmpdir)/$@/lib64/.
	cp -vfa $(install_root_64)/usr/lib64/gconv \
		$(tmpdir)/$@/usr/lib64/.
	$(make_directory) $(tmpdir)/$@$(docdir)
	ln -sf $(libc) $(tmpdir)/$@$(docdir)/$@
	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..

$(libc)-dev-s390x: $(stamp_install_64) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN

	$(make_directory) $(tmpdir)/$@$(libdir)64
	$(INSTALL_DATA) $(install_root_64)$(libdir)64/*.o $(tmpdir)/$@$(libdir)64/.
	$(INSTALL_DATA) $(install_root_64)$(libdir)64/*.a $(tmpdir)/$@$(libdir)64/.
	rm -f $(tmpdir)/$@$(libdir)64/*_?.a
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
# Don't strip linker scripts.
	@tostrip=; for file in $(tmpdir)/$@$(libdir)64/*; do \
	  case `file $$file` in \
	  *text) ;; *) tostrip="$$tostrip $$file" ;; esac; \
	done; echo "$(STRIP) -g $$tostrip"; \
	$(STRIP) -g $$tostrip
endif
	for f in $(install_root_64)$(libdir)64/lib*.so; do \
	  case "$$f" in \
	  *-$(VERSION).so | *-0.[789].so ) ;; \
	  */libSegFault.so|*/libthread_db.so|*/libdb.so) ;; \
	  *) cp -df $$f $(tmpdir)/$@$(libdir)64/. || exit 1 ;; \
	  esac; \
	done
	cd $(tmpdir)/$@$(libdir)64; \
	for link in `find . -name '*.so' -type l`; do \
	  linksrc=$$(readlink $$link | sed 's%../..%%'); \
	  rm -f $$link; ln -sf $$linksrc $$link; done

	# IBM zSeries has a 32/64 build setup, make sure we support it
	$(make_directory) $(tmpdir)/$@$(includedir)
	cp -R $(LINUX_SOURCE)/include/asm-s390x \
		$(tmpdir)/$@$(includedir)/.
	# Remove cruft from CVS trees
	find $(tmpdir)/$@$(includedir)/ -name CVS -type d | xargs -r rm -rf
	find $(tmpdir)/$@$(includedir)/ -name '.#*' -type f | xargs rm -f

	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	# cp -a debian/libc-dev/{postinst,prerm} $(tmpdir)/$@/DEBIAN

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
