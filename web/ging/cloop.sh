#!/bin/bash
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.
set -e

if ! [ "$#" = "1" ] ; then
  echo "Usage: $0 ging.cloop"
  exit 1
fi
touch $1
target=`realpath $1`
rm -f ${target}

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

for i in mkisofs ; do
  if ! dpkg -s ${i} | grep -q "^Status: .* installed$" > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

. vars
cd tmp

set -x

##################
#  add some trickery
###########################

# misc cleanup
chroot . apt-get clean
rm -rf var/cache/apt/lists
dirs="tmp var/lock var/tmp"
rm -rf ${dirs}
mkdir -p ${dirs}
chmod 1777 ${dirs}

# Ging-like feel
echo > etc/motd

# Hide ugly errors ;)
clear > etc/issue
cat >> etc/issue << __EOF__
Ging ${version} \n \l

(login as ${username})

__EOF__

# setup ging user, with password-less login and sudo access
if ! grep -q "^${username}" etc/shadow ; then
  echo "Beware: invoking possibly-buggy adduser"
  chroot . adduser --disabled-password ${username}
fi
for i in root ${username} ; do
  sed -i etc/shadow -e "s/^${i}:[^:]*:/${i}::/g"
done
if ! grep -q "^${username}" etc/sudoers ; then
  cat >> etc/sudoers << __EOF__
${username} ALL=NOPASSWD: ALL
__EOF__
fi

# if X server auto-configurator is installed, enable it
if test -e etc/init.d/xserver-xorg ; then
  rm -f etc/X11/xorg.conf*
  touch etc/X11/xorg.conf
  cat > etc/default/xorg << __EOF__
GENERATE_XCFG_AT_BOOT=true
__EOF__
fi

# if kdm is installed, tell it to auto-login as ging
if test -e etc/kde3/kdm/kdmrc ; then
  sed -i etc/kde3/kdm/kdmrc \
  -e "s/^#AutoLoginEnable=.*/AutoLoginEnable=true/g" \
  -e "s/^#AutoLoginUser=.*/AutoLoginUser=${username}/g"
fi

if ! grep -q xinit home/${username}/.bashrc ; then
  echo "case \`tty\` in /dev/ttyv*) xinit \`which startkde\` && sudo halt ;; esac" >> home/${username}/.bashrc
fi

# avoid non-sense wizards for kde and gimp
tar --same-owner -xzpf ${pwd}/home_ging.tar.gz

if [ "${OPTS}" != "qemu" ] ; then
  # probe for sound cards
  cat > etc/modules.d/ging << EOF
# added for ging ${version}
snd_driver
EOF
else
  cat > etc/modules.d/ging << EOF
# qemu optimised build, no sound support
EOF
fi

# crosshurd gathers some defaults from host machine, we don't really want that
echo -n > etc/resolv.conf
echo "127.0.0.1		localhost $hostname" > etc/hosts
echo $hostname > etc/hostname

# filesystem tables
cat > etc/fstab << EOF
/dev/md2	/	ufs		rw	0 0
EOF
ln -sf /proc/mounts etc/mtab

#########################
#                    ignition!
#################################
# -r messes up file permissions, use -R instead
tmp=`mktemp`
mkisofs -o ${tmp} -R .
if [ "${OPTS}" = "qemu" ] ; then
  args="-L 0"
fi
create_compressed_fs ${args} ${tmp} ${target}
rm -f ${tmp}

cd ${pwd}/
