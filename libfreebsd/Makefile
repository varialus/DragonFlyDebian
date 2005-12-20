#
# libfreebsd
#
# $Id: Makefile 905 2005-12-20 20:29:47Z aurel32 $
#

LIB_SRCS = nlist.c getbootfile.c

LIB_FREEBSDINCLUDES = include/freebsd/paths.h
LIB_INCLUDES = include/nlist.h

LIB_MANS = man/nlist.3 man/getbootfile.3

LIB_STATIC_OBJS = $(LIB_SRCS:%.c=%.o)
LIB_SHARED_OBJS = $(LIB_SRCS:%.c=%.lo)

LIB_NAME = libfreebsd
LIB_VERSION_MAJOR = 0
LIB_VERSION_MINOR = 0

LIB_STATIC = $(LIB_NAME).a

LIB_SHARED_SO = $(LIB_NAME).so
LIB_SONAME = $(LIB_SHARED_SO).$(LIB_VERSION_MAJOR)
LIB_SHARED = $(LIB_SONAME).$(LIB_VERSION_MINOR)

MK_CFLAGS = -Iinclude/ -D_GNU_SOURCE

libs: $(LIB_STATIC) $(LIB_SHARED_SO)

%.lo: %.c
	$(CC) -o $@ $(MK_CFLAGS) $(CFLAGS) -DPIC -fPIC -c $<

%.o: %.c
	$(CC) -o $@ $(MK_CFLAGS) $(CFLAGS) -c $<

$(LIB_STATIC): $(LIB_STATIC_OBJS)
	ar rcs $@ $^

$(LIB_SHARED_SO): $(LIB_SONAME)
	ln -fs $^ $@

$(LIB_SONAME): $(LIB_SHARED)
	ln -fs $^ $@

$(LIB_SHARED): $(LIB_SHARED_OBJS)
	gcc -shared \
	  -Wl,-soname -Wl,$(LIB_SONAME) \
	  -Wl,--version-script=Versions \
	  -o $@ $^

install: libs
	mkdir -p $(DESTDIR)/usr/lib/
	mkdir -p $(DESTDIR)/usr/include/freebsd/
	mkdir -p $(DESTDIR)/usr/share/man/man3
	install -m644 $(LIB_STATIC) $(DESTDIR)/usr/lib/
	install -m644 $(LIB_SHARED) $(DESTDIR)/usr/lib/
	install -m644 $(LIB_INCLUDES) $(DESTDIR)/usr/include/
	install -m644 $(LIB_FREEBSDINCLUDES) $(DESTDIR)/usr/include/freebsd
	install -m644 $(LIB_MANS) $(DESTDIR)/usr/share/man/man3
	cd $(DESTDIR)/usr/lib/ ; ln -fs $(LIB_SHARED) $(LIB_SHARED_SO)
	cd $(DESTDIR)/usr/lib/ ; ln -fs $(LIB_SHARED) $(LIB_SONAME)

clean:
	rm -f $(LIB_STATIC_OBJS)
	rm -f $(LIB_STATIC)
	rm -f $(LIB_SHARED_OBJS)
	rm -f $(LIB_SHARED) $(LIB_SONAME) $(LIB_SHARED_SO)

