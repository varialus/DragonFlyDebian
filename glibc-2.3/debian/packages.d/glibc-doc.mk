$(glibc)-doc:	$(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@$(infodir)
	$(INSTALL_DATA) $(install_root)$(infodir)/*.info* $(tmpdir)/$@$(infodir)/.
	-gzip -9f $(tmpdir)/$@$(infodir)/*

	$(make_directory) $(tmpdir)/$@$(mandir)/man3
	$(INSTALL_DATA) $(srcdir)/linuxthreads/man/*.man \
		$(tmpdir)/$@$(mandir)/man3/.
	for manfile in $(tmpdir)/$@$(mandir)/man3/*; do \
		mv $$manfile `echo $$manfile | sed 's/\.man/\.3/'`; \
	done
	-gzip -9f $(tmpdir)/$@$(mandir)/man?/*
	for manfile in pthread_getspecific.3.gz pthread_key_delete.3.gz \
			 pthread_setspecific.3.gz; do \
		ln -sf pthread_key_create.3.gz \
			$(tmpdir)/$@$(mandir)/man3/$$manfile ;	\
	done

	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(MAKE) -C $(objdir) subdirs=manual info
	cd $(srcdir)/manual && texi2html -split_chapter libc.texinfo
	$(make_directory) $(tmpdir)/$@$(docdir)/$@/html
	$(INSTALL_DATA) $(srcdir)/manual/*.html $(tmpdir)/$@$(docdir)/$@/html/.
	ln -sf libc.html $(tmpdir)/$@$(docdir)/$@/html/index.html
	# This is blank for some reason
	rm -f $(tmpdir)/$@$(docdir)/$@/html/chapters.html
	$(INSTALL_DATA) $(srcdir)/manual/dir-add.info \
	$(tmpdir)/$@$(docdir)/$@/libc.info
	-gzip -f9 $(tmpdir)/$@$(docdir)/$@/libc.info
	$(INSTALL_DATA) $(srcdir)/ChangeLog* $(tmpdir)/$@$(docdir)/$@/.
	-gzip -f9 $(tmpdir)/$@$(docdir)/$@/ChangeLog*
	ln -sf ChangeLog.gz $(tmpdir)/$@$(docdir)/$@/changelog.gz
	$(INSTALL_DATA) $(srcdir)/linuxthreads/FAQ.html $(tmpdir)/$@$(docdir)/$@/FAQ.threads.html
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-gzip -f9 $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	cp -a debian/$@/* $(tmpdir)/$@
	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
