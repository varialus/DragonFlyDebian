source_files := $(shell find -maxdepth 1 -type f -print | grep -v version | grep -v prep.sh)

orig-source: ../glibc_$(VERSION).orig.tar.gz
../glibc_$(VERSION).orig.tar.gz: $(source_files)
	-mv $@ $@~
	-[ -d ../glibc-$(VERSION).orig ] && rm -rf ../glibc-$(VERSION).orig
	mkdir ../glibc-$(VERSION).orig
	cp -a $(source_files) ../glibc-$(VERSION).orig/.
	(cd .. && tar cf - glibc-$(VERSION).orig | gzip -9v) > $@
	rm -rf ../glibc-$(VERSION).orig

source: clean ../glibc_$(VERSION).orig.tar.gz
	cd .. && dpkg-source -b glibc-$(VERSION)
