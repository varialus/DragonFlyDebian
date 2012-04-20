TESTS = \
	type_collision.o \
	uintXX_t.o \
	\
	bus.o \
	cpufunc.o \
	in_pcb.o \
	ppp.o \
	soundcard.o \
	usb.o \
	$()

CFLAGS = -Iinclude -I../debian/kfreebsd-kernel-headers/usr/include

all: $(TESTS)

clean:
	rm -f $(TESTS)
