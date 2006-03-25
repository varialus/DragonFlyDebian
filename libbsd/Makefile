#
# libbsd
#
# $Id$
#

LIB_SRCS := arc4random.c bsd_getopt.c err.c fgetln.c inet_net_pton.c \
	    strlcat.c strlcpy.c md5c.c fmtcheck.c progname.c vis.c unvis.c
LIB_SRCS := $(patsubst %,src/%,$(LIB_SRCS))

LIB_INCLUDES := bsd/err.h bsd/getopt.h bsd/ip_icmp.h bsd/random.h bsd/queue.h bsd/md5.h bsd/string.h \
		bsd/bsd.h bsd/cdefs.h bsd/stdlib.h vis.h

LIB_MANS := arc4random.3 strlcpy.3 fgetln.3 fmtcheck.3
LIB_MANS := $(patsubst %,man/%,$(LIB_MANS))

LIB_STATIC_OBJS = $(LIB_SRCS:%.c=%.o)
LIB_SHARED_OBJS = $(LIB_SRCS:%.c=%.lo)

LIB_NAME = libbsd
LIB_VERSION_MAJOR = 0
LIB_VERSION_MINOR = 0

LIB_STATIC = $(LIB_NAME).a

LIB_SHARED_SO = $(LIB_NAME).so
LIB_SONAME = $(LIB_SHARED_SO).$(LIB_VERSION_MAJOR)
LIB_SHARED = $(LIB_SONAME).$(LIB_VERSION_MINOR)

MK_CFLAGS = -Iinclude/ -include bsd/bsd.h -D_GNU_SOURCE

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
	mkdir -p $(DESTDIR)/usr/lib/ $(DESTDIR)/lib/
	mkdir -p $(DESTDIR)/usr/include/bsd/
	mkdir -p $(DESTDIR)/usr/share/man/man3
	install -m644 $(LIB_STATIC) $(DESTDIR)/usr/lib/
	install -m644 $(LIB_SHARED) $(DESTDIR)/lib/
	for i in $(LIB_INCLUDES) ; do install -m644 include/$$i $(DESTDIR)/usr/include/$$i ; done
	install -m644 $(LIB_MANS) $(DESTDIR)/usr/share/man/man3
	ln -sf /lib/$(LIB_SHARED) $(DESTDIR)/usr/lib/$(LIB_SHARED_SO)
	ln -sf $(LIB_SHARED) $(DESTDIR)/lib/$(LIB_SONAME)

clean:
	rm -f $(LIB_STATIC_OBJS)
	rm -f $(LIB_STATIC)
	rm -f $(LIB_SHARED_OBJS)
	rm -f $(LIB_SHARED) $(LIB_SONAME) $(LIB_SHARED_SO)

