KERNEL=GENERIC
PATH:=/usr/lib/freebsd:$(PATH)
DESTDIR=$(CURDIR)/debian/kfreebsd5
#CFLAGS="-U__linux__ -U__FreeBSD_kernel__ -D__FreeBSD_kernel__=5 -D__FreeBSD_version=502010"
MAKE=make DESTDIR=$(DESTDIR) WERROR=

build/kfreebsd5:: pre-build apply-patches
	if ! test -e debian/stamp-build ; then \
	cd build-tree/src/sys/i386/conf && \
		config $(KERNEL) ; \
	cd ../compile/$(KERNEL)/ && \
		$(MAKE) depend && $(MAKE) ; \
	cd $(CURDIR) ; \
	touch debian/stamp-build ; \
	fi

binary/kfreebsd5:: common-install-prehook-arch
	# setup directories to install into first
	for i in $(kfreebsd5_MKDIR); do \
		install -d -m 755 -o root -g root $(DESTDIR)/$$i; \
	done
	# first install loader
#	cd $(CURDIR)/build-tree/src/sys/boot && \
#		$(MAKE) install
	# install device.hints
	install -o root -g root -m 644 \
		build-tree/src/sys/i386/conf/GENERIC.hints \
		$(DESTDIR)/boot/device.hints
	install -o root -g root -m 644 \
		build-tree/src/sys/boot/forth/loader.conf \
		 $(DESTDIR)/boot/loader.conf
	install -o root -g root -m 644 \
		build-tree/src/sys/boot/forth/loader.conf \
		 $(DESTDIR)/boot/defaults/loader.conf
	# now install the kernel
	cd build-tree/src/sys/i386/compile/$(KERNEL) && \
		$(MAKE) install
	chmod 644 $(DESTDIR)/boot/kernel/kernel

clean::
	rm -f debian/stamp-build
