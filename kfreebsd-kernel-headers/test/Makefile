TESTS = \
	bus.o \
	cpufunc.o \
	in_pcb.o \
	ppp.o \
	soundcard.o \
	usb.o \
	$()

CFLAGS = -I../debian/kfreebsd-kernel-headers/usr/include

all: $(TESTS)

clean:
	rm -f $(TESTS)
