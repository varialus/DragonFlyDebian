TESTS = \
	usb.o \
	soundcard.o \
	$()

CFLAGS = -isystem=../debian/kfreebsd-kernel-headers/usr/include

all: $(TESTS)

clean:
	rm -f $(TESTS)
