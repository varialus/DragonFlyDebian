$(libc)-dev: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@/DEBIAN
	$(make_directory) $(tmpdir)/$@$(bindir)
	$(INSTALL_PROGRAM) $(addprefix $(install_root)$(bindir)/, \
	gencat getconf mtrace rpcgen) $(tmpdir)/$@$(bindir)/.

	$(make_directory) $(tmpdir)/$@$(mandir)/man1
	$(INSTALL_DATA) $(addprefix debian/manpages/, getconf.1 rpcgen.1) \
		$(tmpdir)/$@$(mandir)/man1/.
	-gzip -9f $(tmpdir)/$@$(mandir)/man?/*

ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
	-$(STRIP) --strip-unneeded -R .comment -R .note $(tmpdir)/$@$(bindir)/*
endif
	$(make_directory) $(tmpdir)/$@$(libdir)
	$(INSTALL_DATA) $(install_root)$(libdir)/*.o $(tmpdir)/$@$(libdir)/.
	$(INSTALL_DATA) $(install_root)$(libdir)/*.a $(tmpdir)/$@$(libdir)/.
	rm -f $(tmpdir)/$@$(libdir)/*_?.a
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
# Don't strip linker scripts.
	@tostrip=; for file in $(tmpdir)/$@$(libdir)/*; do \
	  case `file $$file` in \
	  *text) ;; *) tostrip="$$tostrip $$file" ;; esac; \
	done; echo "$(STRIP) -g $$tostrip"; \
	$(STRIP) -g $$tostrip
endif
# Install development links.
	for f in $(install_root)$(libdir)/lib*.so; do \
	  case "$$f" in \
	  *-$(VERSION).so | *-0.[789].so ) ;; \
	  */libSegFault.so|*/libthread_db.so|*/libdb.so) ;; \
	  *) cp -df $$f $(tmpdir)/$@$(libdir)/. || exit 1 ;; \
	  esac; \
	done
ifneq ($(libdir),/lib)
# Make links absolute, not relative
	cd $(tmpdir)/$@$(libdir); \
	for link in `find . -name '*.so' -type l`; do \
	  linksrc=$$(readlink $$link | sed 's%../..%%'); \
	  rm -f $$link; ln -sf $$linksrc $$link; done
endif
	$(make_directory) $(tmpdir)/$@$(includedir)
	cp -a $(install_root)$(includedir) $(tmpdir)/$@/usr/
ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
	$(make_directory) $(addprefix $(LINUX_SOURCE)/include/,asm linux)
	cp -R $(LINUX_SOURCE)/include/linux/. $(tmpdir)/$@$(includedir)/linux/
	cp -R $(LINUX_SOURCE)/include/asm/. $(tmpdir)/$@$(includedir)/asm/
ifeq ($(DEB_HOST_GNU_CPU),sparc)
# Sparc has a 32/64 build setup, make sure we support it
	cp -R $(LINUX_SOURCE)/include/asm-sparc \
		$(tmpdir)/$@$(includedir)/.
	cp -R $(LINUX_SOURCE)/include/asm-sparc64 \
		$(tmpdir)/$@$(includedir)/.
	$(INSTALL_PROGRAM) $(LINUX_SOURCE)/generate-asm.sh \
		$(tmpdir)/$@$(bindir)/generate-asm
	$(tmpdir)/$@$(bindir)/generate-asm $(tmpdir)/$@$(includedir)/
	rm -rf $(tmpdir)/$@$(includedir)/asm-sparc64
else
ifeq ($(DEB_HOST_GNU_CPU),s390)
	# IBM zSeries has a 32/64 build setup, make sure we support it
	cp -R $(LINUX_SOURCE)/include/asm-{s390,s390x} \
	$(tmpdir)/$@$(includedir)/.
	$(INSTALL_PROGRAM) $(LINUX_SOURCE)/generate-asm.sh \
	$(tmpdir)/$@$(bindir)/generate-asm
	$(tmpdir)/$@$(bindir)/generate-asm $(tmpdir)/$@$(includedir)/
	rm -rf $(tmpdir)/$@$(includedir)/asm-s390x
else
	cp -R $(LINUX_SOURCE)/include/asm/. $(tmpdir)/$@$(includedir)/asm/
endif
endif
	rm -rf $(tmpdir)/$@$(includedir)/linux/modules
	rm -f $(tmpdir)/$@$(includedir)/linux/modversions.h
endif
# Remove cruft from CVS trees
	find $(tmpdir)/$@$(includedir)/ -name CVS -type d | xargs -r rm -rf
	find $(tmpdir)/$@$(includedir)/ -name '.#*' -type f | xargs rm -f
	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	cp -a debian/$@/* $(tmpdir)/$@/DEBIAN

	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@ $(libc_dev_control_flags)
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..

