$(libc)-pic: $(stamp_install) debian/control $(mkdir)/sysdeps.mk
	$(checkroot)
	$(debian-clean)
	-rm -rf $(tmpdir)/$@

	$(make_directory) $(tmpdir)/$@$(libdir)/libc_pic
	$(INSTALL_DATA) $(objdir)/libc_pic.a $(tmpdir)/$@$(libdir)/.
	$(INSTALL_DATA) $(objdir)/libc.map $(tmpdir)/$@$(libdir)/libc_pic.map
	$(INSTALL_DATA) $(objdir)/elf/soinit.os $(tmpdir)/$@$(libdir)/libc_pic/soinit.o
	$(INSTALL_DATA) $(objdir)/elf/sofini.os $(tmpdir)/$@$(libdir)/libc_pic/sofini.o

	$(INSTALL_DATA) $(objdir)/math/libm_pic.a $(tmpdir)/$@$(libdir)/.
	$(INSTALL_DATA) $(objdir)/libm.map $(tmpdir)/$@$(libdir)/libm_pic.map
	$(INSTALL_DATA) $(objdir)/resolv/libresolv_pic.a $(tmpdir)/$@$(libdir)/.
	$(INSTALL_DATA) $(objdir)/libresolv.map $(tmpdir)/$@$(libdir)/libresolv_pic.map
ifeq ($(DEB_HOST_GNU_SYSTEM),gnu)
	$(INSTALL_DATA) $(objdir)/hurd/libhurduser_pic.a $(tmpdir)/$@$(libdir)/.
	$(INSTALL_DATA) $(objdir)/mach/libmachuser_pic.a $(tmpdir)/$@$(libdir)/.
endif
ifeq ($(DEB_BUILD_OPTION_STRIP),yes)
	$(STRIP) -g $(tmpdir)/$@$(libdir)/lib*_pic.a
endif
	$(make_directory) $(tmpdir)/$@$(docdir)/$@
	$(INSTALL_DATA) debian/changelog $(tmpdir)/$@$(docdir)/$@/changelog.Debian
	-find $(tmpdir)/$@$(docdir)/$@ -type f | xargs -r gzip -9f
	$(INSTALL_DATA) debian/copyright $(tmpdir)/$@$(docdir)/$@/.

	$(make_directory) $(tmpdir)/$@/DEBIAN
	find $(tmpdir)/$@ -name CVS -print -prune | xargs --no-run-if-empty rm -rf
	dpkg-gencontrol -isp -p$@ -P$(tmpdir)/$@
	chown -R root.root $(tmpdir)/$@
	chmod -R go=rX $(tmpdir)/$@
	dpkg --build $(tmpdir)/$@ ..
