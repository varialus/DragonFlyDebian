# -*- mode: makefile; coding: utf-8 -*-
#  # Copyright © 2003 Jeff Bailey <jbailey@debian.org>
# Description: A class for Tarball-based packages;
# facilitates unpacking into a directory and setting DEB_SRCDIR and
# DEB_BUILDDIR appropriately.  Note that tarball.mk MUST come
# *FIRST* in the list of included rules.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

ifndef _cdbs_rules_tarball
_cdbs_rules_tarball := 1

include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

ifeq ($(DEB_TAR_SRCDIR),)
$(error You must specify DEB_TAR_SRCDIR)
endif

_cdbs_tarball_dir := build-tree

DEB_SRCDIR = $(_cdbs_tarball_dir)/$(DEB_TAR_SRCDIR)
DEB_BUILDDIR ?= $(DEB_SRCDIR)

# The user developper may override this variable to choose which tarballs
# to unpack.

DEB_TARBALL ?= $(wildcard *.tgz *.tar.gz *.tar.bz *.tar.bz2 *.zip)

# This is not my finest piece of work.
# Essentially, it's never right to unpack a tarball more than once
# so we have to emit stamps.  The stamps then have to be the rule
# we use.  Then we have to figure out what file we're working on
# based on the stamp name.  Also, tar-gzip archives can be either
# .tar.gz or .tgz.  tar-bzip archives can be either tar.bz or tar.bz2

_cdbs_tarball_stamps = $(addprefix debian/stamp-,$(DEB_TARBALL))
_cdbs_tarball_stamp_base = $(basename $(_cdbs_tarball_stamps))

pre-build:: $(_cdbs_tarball_stamps)

$(addsuffix .gz,$(_cdbs_tarball_stamp_base)) $(addsuffix .tgz,$(_cdbs_tarball_stamp_base)):
	tar -C $(_cdbs_tarball_dir) -xzf $(patsubst stamp-%,%,$(notdir $@))
	touch $@

$(addsuffix .bz,$(_cdbs_tarball_stamp_base)) $(addsuffix .bz2,$(_cdbs_tarball_stamp_base)):
	tar -C $(_cdbs_tarball_dir) -xjf $(patsubst stamp-%,%,$(notdir $@))
	touch $@

$(addsuffix .zip,$(_cdbs_tarball_stamp_base)):
	unzip $(patsubst stamp-%,%,$(notdir $@)) -d $(_cdbs_tarball_dir)
	touch $@

cleanbuilddir::
	rm -rf $(_cdbs_tarball_dir)
# Ignore errors from this.  These stamps may not exist yet.
	-rm $(_cdbs_tarball_stamps)

endif
