locales: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	# Don't let the build system compile locales
	if [ ! -e $(srcdir)/localedata/SUPPORTED.orig ]; then \
		mv $(srcdir)/localedata/SUPPORTED $(srcdir)/localedata/SUPPORTED.orig; \
		touch $(srcdir)/localedata/SUPPORTED; \
	fi

	$(MAKE) -C $(srcdir)/localedata install_root=$(install_root) \
		objdir=$(objdir) install-locales

	$(make_directory) $(tmpdir)/$@$(datadir)/.
	cp -a $(install_root)$(datadir)/locale $(tmpdir)/$@$(datadir)/.
	cp -a $(install_root)$(datadir)/i18n $(tmpdir)/$@$(datadir)/.
	$(make_directory) $(tmpdir)/$@$(libdir)/locale
	$(make_directory) $(tmpdir)/$@/etc
	mv -f $(tmpdir)/$@$(datadir)/locale/locale.alias $(tmpdir)/$@/etc/.
	ln -sf /etc/locale.alias $(tmpdir)/$@$(datadir)/locale/locale.alias

	$(make_directory) $(tmpdir)/$@$(docdir)/$@/

	$(MAKE) -f debian/generate-supported.mk IN=$(srcdir)/localedata/SUPPORTED.orig \
		OUT=$(tmpdir)/$@$(datadir)/i18n/SUPPORTED

	$(make_directory) $(tmpdir)/$@$(mandir)/man8
	$(INSTALL_DATA) $(addprefix debian/manpages/, \
		locale-gen.8) $(tmpdir)/$@$(mandir)/man8/.
	$(make_directory) $(tmpdir)/$@$(mandir)/man5
	$(INSTALL_DATA) $(addprefix debian/manpages/, \
		locale.alias.5 locale.gen.5) $(tmpdir)/$@$(mandir)/man5/.

	$(INSTALL_DATA) $(srcdir)/localedata/ChangeLog $(tmpdir)/$@$(docdir)/$@/changelog
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	$(INSTALL_DATA) $(srcdir)/localedata/README $(tmpdir)/$@$(docdir)/$@/.
	-gzip -9f $(tmpdir)/$@$(docdir)/$@/*
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	for dirs in usr; do \
		cp -a debian/locales/$$dirs $(tmpdir)/$@/ ; \
	done
	$(make_directory) $(tmpdir)/$@/DEBIAN
	for files in conffiles config postinst postrm; do \
		cp debian/locales/DEBIAN/$$files $(tmpdir)/$@/DEBIAN/ ; \
	done
	po2debconf --podir=debian/po debian/locales/DEBIAN/templates > $(tmpdir)/$@/DEBIAN/templates

	# Add in the list of SUPPORTED locales
	perl -i -pe 'BEGIN {undef $$/; open(IN, "'"$(tmpdir)/$@$(datadir)/i18n/SUPPORTED"'"); $$j=<IN>;} s/__SUPPORTED_LOCALES__/$$j/g;' $(tmpdir)/$@/DEBIAN/config

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@ $($@_control_flags) \
		-DDepends="glibc-$(DEBVERSION), debconf (>= 0.2.26)"
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
