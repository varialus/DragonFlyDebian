ifeq ($(DEB_HOST_GNU_TYPE),$(DEB_BUILD_GNU_TYPE))
cross_compiling := no
else
cross_compiling := yes
endif

include $(mkdir)/config.mk
include $(mkdir)/paths.mk
include $(mkdir)/soname.mk
include $(mkdir)/depflags.mk
include $(mkdir)/tools.mk
-include $(mkdir)/$(DEB_HOST_GNU_CPU).mk
-include $(mkdir)/$(DEB_HOST_GNU_SYSTEM).mk
-include $(mkdir)/$(DEB_HOST_GNU_TYPE).mk

ifeq ($(RELEASE),experimental)
glibc := glibc-$(RELEASE)
else
glibc := glibc
endif

include $(mkdir)/build-options.mk

ifeq ($(DEB_BUILD_OPTION_PARALLEL),yes)
  NPROCS:=$(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
  ifeq ($(NPROCS),0)
    PARALLELMFLAGS=
  else
    ifeq ($(NPROCS),-1)
      PARALLELMFLAGS=
    else
      ifeq ($(NPROCS),1)
	PARALLELMFLAGS=
      else
	ifeq ($(NPROCS),)
	  PARALLELMFLAGS=
	else
	  PARALLELMFLAGS=-j $(shell expr $(NPROCS) + $(NPROCS))
	endif
      endif
    endif
  endif
endif

# Reduce optimization level of build on i386.  This needs to
# be properly put into sysdeps somewhere until the bug is
# fixed. - JB 2002-Oct-17
ifeq ($(DEB_HOST_GNU_CPU),i386)
BUILD_CFLAGS = -O
HOST_CFLAGS = -O
else
BUILD_CFLAGS = -O2
HOST_CFLAGS = -pipe -O2 -fstrict-aliasing
endif

ifeq ($(DEB_BUILD_OPTION_DEBUG),yes)
BUILD_CFLAGS += -g
HOST_CFLAGS += -g
endif
