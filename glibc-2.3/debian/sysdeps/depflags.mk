depflags = libc=$(libc) glibc=$(glibc) \
	  DEB_HOST_GNU_SYSTEM=$(DEB_HOST_GNU_SYSTEM) \
	  DEB_HOST_GNU_TYPE=$(DEB_HOST_GNU_TYPE) \
	  perl debian/sysdeps/depflags.pl

libc_control_flags = $(shell $(depflags) libc)
libc_dev_control_flags = $(shell $(depflags) libc_dev)
libc_opt_control_flags = $(shell $(depflags) libc_opt)

test_depflags:
	@echo
	@echo "$(libc):"
	@echo '  $(libc_control_flags)'
	@echo
	@echo "$(libc)-dev:"
	@echo '  $(libc_dev_control_flags)'
	@echo
	@echo "$(libc)-opt"
	@echo '  $(libc_opt_control_flags)'
	@echo
