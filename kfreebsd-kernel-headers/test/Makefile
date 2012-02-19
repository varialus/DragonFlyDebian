TESTS = \
	cpufunc.o \
	soundcard.o \
	usb.o \
	$()

CFLAGS = -isystem=../debian/kfreebsd-kernel-headers/usr/include

all: $(TESTS)

clean:
	rm -f $(TESTS)
