$(libc)-prof: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(make_directory) $(tmpdir)/$@$(libdir)

	$(INSTALL_DATA) $(install_root)$(libdir)/*_p.a $(tmpdir)/$@$(libdir)/.

	$(make_directory) $(tmpdir)/$@$(bindir)

	$(INSTALL_PROGRAM) $(install_root)$(bindir)/sprof $(tmpdir)/$@$(bindir)/.

	$(make_directory) $(tmpdir)/$@$(mandir)/man1

	$(INSTALL_DATA) debian/manpages/sprof.1 $(tmpdir)/$@$(mandir)/man1/.
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
	$(STRIP) --strip-unneeded -R .note $(tmpdir)/$@$(bindir)/sprof
# Don't strip linker scripts.
	@tostrip=; for file in \
	`find $(tmpdir)/$@$(libdir) \
	 -type f -name '*.o' -o -name '*.a'`; do \
	  case `file $$file` in \
	  *text) ;; \
	  *) tostrip="$$tostrip $$file" ;; \
	  esac; \
	done; \
	echo "$(STRIP) -g $$tostrip"; \
	$(STRIP) -g $$tostrip
endif
	-gzip -f9 $(tmpdir)/$@$(mandir)/man1/sprof.1

	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
