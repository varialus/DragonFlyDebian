# Directories to create inside the packages, because the stupid BSD make system
# doesn't create them before doing make install.
kfreebsd_MKDIR=/boot/kernel /boot/defaults /boot/modules /usr/lib /usr/share/man/man5 /usr/share/man/man8
