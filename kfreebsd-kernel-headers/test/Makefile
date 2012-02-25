TESTS = \
	cpufunc.o \
	soundcard.o \
	usb.o \
	$()

CFLAGS = -I../debian/kfreebsd-kernel-headers/usr/include

all: $(TESTS)

clean:
	rm -f $(TESTS)
