TESTS = \
	type_collision.o \
	time_collision.o \
	param_collision.o \
	limits_collision.o \
	uintXX_t.o \
	\
	bus.o \
	cpufunc.o \
	in_pcb.o \
	ppp.o \
	soundcard.o \
	sys_sysctl.o \
	usb.o \
	$()

CFLAGS = -Iinclude -I../debian/kfreebsd-kernel-headers/usr/include

# Enable all the stuff in glibc to probe for collisions
CFLAGS += -D_GNU_SOURCE -Werror

all: $(TESTS)

clean:
	rm -f $(TESTS)
