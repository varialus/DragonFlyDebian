$(libc)-dbg: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(make_directory) $(tmpdir)/$@$(libdir)/debug
	$(INSTALL_DATA) $(install_root)/lib/*-$(VERSION).so \
		$(tmpdir)/$@$(libdir)/debug/.
ifeq ($(threads),yes)
	$(INSTALL_DATA) $(install_root)/lib/libpthread-0.10.so \
	$(tmpdir)/$@$(libdir)/debug/libpthread-0.10.so
	$(INSTALL_DATA) $(install_root)/lib/libthread_db-1.0.so \
	$(tmpdir)/$@$(libdir)/debug/.
endif
	for link in `find $(install_root)/lib -type l \
	-name '*.so.*' ! -name 'libnss*_*.so.1*'`; do \
	cp -vdf $$link $(tmpdir)/$@$(libdir)/debug; done

	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	gzip -9fv $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	# Make ld.so executable
	chmod 755 $(tmpdir)/$@$(libdir)/debug/ld-$(VERSION).so
	dpkg --build $(tmpdir)/$@ ..
