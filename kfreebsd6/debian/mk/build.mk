KERNEL		:= GENERIC
PATH		:= /usr/lib/freebsd:$(PATH)
DESTDIR		:= $(CURDIR)/debian/kfreebsd$(major)
MAKE		:= make DESTDIR=$(DESTDIR) WERROR=
revision	:= `dpkg-parsechangelog | grep ^Version | cut -c 10- | cut -d '-' -f 2`
kfreebsd_cpu	:= $(DEB_HOST_GNU_CPU)
ifeq ($(kfreebsd_cpu), x86_64)
kfreebsd_cpu	:= amd64
endif

build/kfreebsd$(major):: debian/stamp-build
debian/stamp-build: apply-patches
	cd $(DEB_SRCDIR)/sys/$(kfreebsd_cpu)/conf \
		&& config $(KERNEL)
	cd $(DEB_SRCDIR)/sys/$(kfreebsd_cpu)/compile/$(KERNEL)/ \
		&& $(MAKE) depend && $(MAKE)

	touch debian/stamp-build

binary/kfreebsd$(major):: common-install-prehook-arch
	# setup directories to install into first
	for i in $(kfreebsd_MKDIR); do \
		install -d -m 755 -o root -g root $(DESTDIR)/$$i; \
	done
	# install device.hints
	install -o root -g root -m 644 \
		$(DEB_SRCDIR)/sys/$(kfreebsd_cpu)/conf/GENERIC.hints \
		$(DESTDIR)/boot/device.hints
	install -o root -g root -m 644 \
		$(DEB_SRCDIR)/sys/boot/forth/loader.conf \
		 $(DESTDIR)/boot/loader.conf
	install -o root -g root -m 644 \
		$(DEB_SRCDIR)/sys/boot/forth/loader.conf \
		 $(DESTDIR)/boot/defaults/loader.conf
	# now install the kernel
	cd $(DEB_SRCDIR)/sys/$(kfreebsd_cpu)/compile/$(KERNEL) && \
		$(MAKE) install
	chmod 644 $(DESTDIR)/boot/kernel/kernel
	gzip -c9 $(DESTDIR)/boot/kernel/kernel > \
		$(DESTDIR)/boot/kfreebsd.gz

	# prevent init barfs when / is cd9660
	mkdir -p $(DESTDIR)/sbin
	cp `which true` $(DESTDIR)/sbin/fsck.cd9660

clean::
	grep -q src/sys/$(kfreebsd_cpu)/conf/GENERIC \
		debian/patches/*.diff

	cat debian/patches/902_debian_version.diff.in \
		| sed "s/@revision@/$(revision)/g" \
		> debian/patches/902_debian_version.diff

	sed \
		-e "s/@kfreebsd-gnu@/`type-handling any kfreebsd-gnu`/g" \
		-e "s/@major@/$(major)/g" \
		-e "s/@version@/$(version)/g" \
	> debian/control.in < debian/control.in.in

	rm -f debian/stamp-build
