#! /usr/bin/make -f

SGML_MAN = locale-gen.8

all: $(patsubst %.pod,%.1,$(wildcard *.pod)) $(SGML_MAN)
%.1: %.pod
	pod2man --center="Debian GNU/Linux" --release="woody" $< > $@

locale-gen.8: locale-gen.8.sgml
	docbook-to-man $< > $@
