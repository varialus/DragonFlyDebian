#!/usr/bin/perl

# These get export by debian/sysdeps/depflags.mk
$DEB_HOST_GNU_SYSTEM = $ENV{'DEB_HOST_GNU_SYSTEM'};
$DEB_HOST_GNU_TYPE = $ENV{'DEB_HOST_GNU_TYPE'};
$libc = $ENV{'libc'};
$glibc = $ENV{'glibc'};
@deptypes = ('Depends', 'Replaces', 'Conflicts', 'Provides',
	     'Suggests');

# Let's make sure we are sane
if (!defined($DEB_HOST_GNU_SYSTEM) or !defined($DEB_HOST_GNU_TYPE) or
    !defined($libc) or !defined($glibc)) {
    die "Could not get all parameters";
}

@ARGV == 1 or die "Usage: depflags <type>";
$type = $ARGV[0];

# OS specific stuff
if ($DEB_HOST_GNU_SYSTEM eq "gnu") {
    push @{$libc_dev_c{'Depends'}}, ('gnumach-dev', 'hurd-dev');
    push @{$libc_dev_c{'Replaces'}}, 'glibc2-dev';
    push @{$libc_dev_c{'Conflicts'}}, 'glibc2-dev';
    push @{$libc_c{'Replaces'}}, 'glibc2';
    push @{$libc_c{'Conflicts'}}, 'glibc2';
    push @{$libc_c{'Depends'}}, 'hurd (>= 20010718-1)';
}
if ($DEB_HOST_GNU_SYSTEM eq "linux") {
    push @{$libc_c{'Suggests'}}, 'locales';
    push @{$libc_c{'Suggests'}}, "${glibc}-doc";
    push @{$libc_c{'Provides'}}, 'gconv-modules';
    #db1 compat libraries from libc 2.0/2.1, we need to depend on them
    #until after sarge is released
    push @{$libc_c{'Depends'}}, "libdb1-compat";
    push @{$libc_dev_c{'Recommends'}}, 'c-compiler';
    push @{$libc_dev_c{'Suggests'}}, "${glibc}-doc";
    push @{$libc_dev_c{'Replaces'}}, ('man-db (<= 2.3.10-41)', 'gettext (<= 0.10.26-1)',
		'ppp (<= 2.2.0f-24)', 'libgdbmg1-dev (<= 1.7.3-24)');
}
if ($DEB_HOST_GNU_SYSTEM eq "kfreebsd-gnu") {
    push @{$libc_dev_c{'Depends'}}, ('kfreebsd-headers');
    push @{$libc_dev_c{'Conflicts'}}, ('libpthread-dev');
    push @{$libc_dev_c{'Replaces'}}, ('libpthread-dev');
    push @{$libc_dev_c{'Conflicts'}}, ('libsem-dev');
    push @{$libc_dev_c{'Replaces'}}, ('libsem-dev');
}
if ($DEB_HOST_GNU_SYSTEM eq "knetbsd-gnu") {
    push @{$libc_dev_c{'Depends'}}, ('knetbsd-headers');
    push @{$libc_dev_c{'Conflicts'}}, ('libpthread-dev');
    push @{$libc_dev_c{'Replaces'}}, ('libpthread-dev');
    push @{$libc_dev_c{'Conflicts'}}, ('libsem-dev');
    push @{$libc_dev_c{'Replaces'}}, ('libsem-dev');
}

# nss-db is now seperate
push @{$libc_c{'Recommends'}}, 'libnss-db';

# Old strace doesn't work with current libc6
push @{$libc_c{'Conflicts'}}, 'strace (<< 4.0-0)';

# 2.1.94 required a patch, applied in gcc -15, so c++ compiles will work again
push @{$libc_dev_c{'Conflicts'}}, 'libstdc++2.10-dev (<< 1:2.95.2-15)';

# 2.2.2+CVS requires a newer gcc. For non-i386, we just worry about the
# weak-sym patch, since on i386 we need an even newer one because of the
# pic-kludge that breaks libc_nonshared.a inclusion.
if ($DEB_HOST_GNU_TYPE =~ m/^i386-linux$/) {
    push @{$libc_dev_c{'Conflicts'}}, 'gcc-2.95 (<< 1:2.95.3-9)';
} else {
    push @{$libc_dev_c{'Conflicts'}}, 'gcc-2.95 (<< 1:2.95.3-8)';
}

# The db2 changes left libnss-db broken, except for the newer version
# which uses db3
push @{$libc_c{'Conflicts'}}, 'libnss-db (<= 2.2-6.1.1)';

# From now on we provide our own ldconfig and ldd, so we don't need ldso
push @{$libc_dev_c{'Replaces'}}, 'ldso (<= 1.9.11-9)';
push @{$libc_c{'Replaces'}}, 'ldso (<= 1.9.11-9)';

# Some old packages from glibc that don't get built, but need to be handled
push @{$libc_c{'Replaces'}}, ('timezone', 'timezones', 'gconv-modules',
	'libtricks', 'initscripts');
push @{$libc_c{'Conflicts'}}, ('timezone', 'timezones', 'gconv-modules',
	'libtricks', "${libc}-doc");

# conflicts from libc5 days
if ($DEB_HOST_GNU_TYPE =~ m/^(i386|m68k)-linux$/) {
    push @{$libc_c{'Conflicts'}}, ('libc5 (<< 5.4.33-7)', 'libpthread0 (<< 0.7-10)');
} elsif ($DEB_HOST_GNU_TYPE eq 'sparc-linux') {
    push @{$libc_c{'Conflicts'}}, ('libc5 (<< 5.3.12-2)', 'libpthread0 (<< 0.7-10)');
}
if ($DEB_HOST_GNU_TYPE =~ m/^(alpha|i386|m68k|sparc)-linux$/) {
    push @{$libc_dev_c{'Conflicts'}}, ('libpthread0-dev', 'libdl1-dev',
	'libdb1-dev', 'libgdbm1-dev');
    # Add this here too, old package
    push @{$libc_c{'Conflicts'}}, ("${libc}-bin", 'libwcsmbs');
    push @{$libc_c{'Replaces'}}, "${libc}-bin";
}

# Old, Pre glibc 2.1
if ($DEB_HOST_GNU_TYPE =~ m/^(alpha|i386|m68k|sparc|powerpc|arm)-linux$/) {
    push @{$libc_dev_c{'Conflicts'}}, ("${libc}-dev (<< 2.0.110-1)",
	'locales (<< 2.1.3-5)');
}

# XXX: Not sure why this conflict is here, maybe broken c++?
if ($DEB_HOST_GNU_TYPE =~ m/^(i386|m68k|alpha)-linux$/) {
    push @{$libc_c{'Conflicts'}}, ('apt (<< 0.3.0)', 'libglib1.2 (<< 1.2.1-2)');
}

# Some old c++ libs
if ($DEB_HOST_GNU_TYPE =~ m/^(alpha|i386)-linux$/) {
    push @{$libc_dev_c{'Conflicts'}}, 'libstdc++2.9-dev';
} elsif ($DEB_HOST_GNU_TYPE eq "powerpc-linux") {
    push @{$libc_dev_c{'Conflicts'}}, ('libstdc++2.9 (<< 2.91.58-2.1)',
	'libstdc++2.8 (<< 2.90.29-1)');
} elsif ($DEB_HOST_GNU_TYPE eq "m68k-linux") {
    push @{$libc_dev_c{'Conflicts'}}, 'libstdc++2.9-dev';
}

# XXX: What is this!?
if ($DEB_HOST_GNU_TYPE eq "alpha-linux") {
    push @{$libc_dev_c{'Conflicts'}}, ('libncurses4-dev (<< 4.2-3.1)',
	'libreadlineg2-dev (<< 2.1-13.1)');
}

# XXX: Our optimized libs do not like some programs
push @{$libc_opt_c{'Conflicts'}}, ('libsafe', "memprof");

# Conflict/Replace netkit-rpc, and its manpages
push @{$libc_c{'Conflicts'}}, 'netkit-rpc';
push @{$libc_c{'Replaces'}}, 'netkit-rpc';
push @{$libc_dev_c{'Conflicts'}}, 'netkit-rpc';
push @{$libc_dev_c{'Replaces'}}, 'netkit-rpc';
push @{$libc_c{'Replaces'}}, 'netbase (<< 4.0)';
push @{$libc_dev_c{'Replaces'}}, 'netbase (<< 4.0)';

# Conflict old wine
push @{$libc_c{'Conflicts'}}, 'wine (<< 0.0.20021007-1)';

# Make sure we only have one version of libc-dev installed
push @{$libc_dev_c{'Provides'}}, 'libc-dev';
push @{$libc_dev_c{'Conflicts'}}, 'libc-dev';
if ($libc ne "libc6") {
    push @{$libc_dev_c{'Provides'}}, 'libc6-dev';
}
if ($type eq "libc") {
    %pkg = %libc_c;
} elsif ($type eq "libc_dev") {
    %pkg = %libc_dev_c;
} elsif ($type eq "libc_opt") {
    %pkg = %libc_opt_c;
} else {
    die "Unknown package $type";
}

foreach $dep (@deptypes) {
    next if not defined($pkg{$dep});
    print "-D${dep}=\"" . join(', ', @{$pkg{$dep}}) . "\" ";
}
