libc-udeb: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/lib
	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(INSTALL_PROGRAM) $(install_root)/lib/ld-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/libc-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/libm-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_DATA) $(install_root)/lib/libdl-$(VERSION).so $(tmpdir)/$@/lib/.
	$(INSTALL_PROGRAM) $(install_root)/lib/libc-$(VERSION).so $(tmpdir)/$@/lib/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(install_root)/lib/libpthread-0.10.so $(tmpdir)/$@/lib/.
endif

ifeq ($(DEB_HOST_GNU_SYSTEM),gnu)
# Why doesn't the glibc makefile install this?
	ln -sf ld.so.1 $(tmpdir)/$@/lib/ld.so
endif

# It is safe to strip the dynamic linker though _dl_debug_state must be kept
# in order for gdb to work.
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
  #ifeq ($(DEB_HOST_GNU_CPU),i386) // Let's try this for all archs
	$(STRIP) -g -K _dl_debug_state -R .note -R .comment $(tmpdir)/$@/lib/ld-$(VERSION).so
  #endif
	cd $(tmpdir)/$@ && \
	$(STRIP) --strip-unneeded -R .note -R .comment lib/lib*-$(VERSION).so
endif

	# Install the libs under their sonames.
	set -ex; cd $(tmpdir)/$@/lib; \
	for f in *.so; do \
	if [ ! -L $$f ]; then \
  	  mv $$f `readelf -W --dynamic $$f | grep SONAME | \
		sed -e 's/.*\[//' -e 's/].*//'`; fi; \
	done

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@ $(libc-udeb_control_flags) \
		-DProvides="$(shell perl debian/debver2localesdep.pl \
		$(DEBVERSION))" -fdebian/files~
	dpkg-distaddfile libc-udeb_$(DEBVERSION)_$(shell dpkg-architecture -qDEB_HOST_ARCH).udeb debian-installer required
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ../libc-udeb_$(DEBVERSION)_$(shell dpkg-architecture -qDEB_HOST_ARCH).udeb

