ifeq ($(cross_compiling),yes)
CC     = $(DEB_HOST_GNU_TYPE)-gcc
BUILD_CC = gcc-3.2
else
CC     = gcc-3.2
BUILD_CC = $(CC)
endif
