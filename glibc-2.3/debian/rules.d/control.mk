# Add opt to this line to generate optimized packages
control_deps := $(addprefix debian/control.in/, libc6 libc6.1 libc0.3 libc0.1 libc1 sparc64 s390x) # 

threads_archs := alpha arm i386 m68k mips mipsel powerpc sparc ia64 hppa s390 sh3 sh4 sh3eb sh4eb

debian/control.in/libc6: debian/control.in/libc debian/rules.d/control.mk
	sed -e 's%@libc@%libc6%g' \
	    -e 's%@archs@%arm i386 m68k mips mipsel powerpc sparc s390 hppa sh3 sh4 sh3eb sh4eb%g' < $< > $@

debian/control.in/libc6.1: debian/control.in/libc debian/rules.d/control.mk
	sed -e 's%@libc@%libc6.1%g;s%@archs@%alpha ia64%g' < $< > $@

debian/control.in/libc0.3: debian/control.in/libc debian/rules.d/control.mk
	sed -e 's%@libc@%libc0.3%g;s%@archs@%hurd-i386%g;s/nscd, //' < $< > $@

debian/control.in/libc0.1: debian/control.in/libc debian/rules.d/control.mk
	sed -e 's%@libc@%libc0.1%g;s%@archs@%kfreebsd-i386%g' < $< > $@

debian/control.in/libc1: debian/control.in/libc debian/rules.d/control.mk
	sed -e 's%@libc@%libc1%g;s%@archs@%netbsd-i386%g' < $< > $@

debian/control: debian/control.in/main $(DEB_HOST_GNU_TYPE) $(control_deps) \
		   debian/sysdeps/soname.mk debian/sysdeps/config.mk \
		   debian/rules.d/control.mk debian/sysdeps/depflags.pl
	cat debian/control.in/main		>  $@T
	cat debian/control.in/libc6		>> $@T
	cat debian/control.in/libc6.1		>> $@T
	cat debian/control.in/libc0.3		>> $@T
	cat debian/control.in/libc0.1		>> $@T
	cat debian/control.in/libc1		>> $@T
	cat debian/control.in/sparc64		>> $@T
	cat debian/control.in/s390x		>> $@T
#	Uncomment this line to enable optimized packages
#	cat debian/control.in/opt		>> $@T
	cat debian/control.in/libc-udeb         >> $@T
	sed -e 's%@libc@%$(libc)%g;s%@glibc@%$(glibc)%g' \
	    -e 's%@threads_archs@%$(threads_archs)%g' < $@T > $@
	rm $@T
