ifeq ($(cross_compiling),yes)
CC     = $(DEB_HOST_GNU_TYPE)-gcc
BUILD_CC = gcc-3.3
else
CC     = gcc-3.3
BUILD_CC = $(CC)
endif
