nscd: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@$(sbindir)

	$(INSTALL_PROGRAM) $(install_root)$(sbindir)/nscd \
		$(tmpdir)/$@$(sbindir)/.
	$(INSTALL_PROGRAM) $(install_root)$(sbindir)/nscd_nischeck \
		$(tmpdir)/$@$(sbindir)/.
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
	$(STRIP) --strip-unneeded -R .note $(tmpdir)/$@$(sbindir)/nscd*
endif
	cp -a debian/$@/* $(tmpdir)/$@

	$(INSTALL_DATA) $(srcdir)/nscd/nscd.conf $(tmpdir)/$@/etc/nscd.conf

	$(make_directory) $(tmpdir)/$@$(docdir)/$@

	$(INSTALL_DATA) debian/changelog \
		$(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright \
		$(tmpdir)/$@$(docdir)/$@/copyright

	$(make_directory) $(tmpdir)/$@$(mandir)/man5
	$(INSTALL_DATA) $(addprefix debian/manpages/, nscd.conf.5) \
                $(tmpdir)/$@$(mandir)/man5/.
	$(make_directory) $(tmpdir)/$@$(mandir)/man8
	$(INSTALL_DATA) $(addprefix debian/manpages/, nscd.8 nscd_nischeck.8) \
		$(tmpdir)/$@$(mandir)/man8/.
	-gzip -9f $(tmpdir)/$@$(mandir)/man?/*

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
