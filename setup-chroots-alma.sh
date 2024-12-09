#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

. "${0%/*}/vars.conf"

BASE=https://images.linuxcontainers.org/images/almalinux/9/amd64/default/

LAST=$(wget -o /dev/null $BASE -O - | grep href | tail -n1 | awk -F '"' '{print $2}')

URL="${BASE}${LAST}rootfs.tar.xz"
RPM_libdvbcsa="https://download1.rpmfusion.org/free/el/updates/9/x86_64/l/libdvbcsa-devel-1.1.0-15.el9.x86_64.rpm https://download1.rpmfusion.org/free/el/updates/9/x86_64/l/libdvbcsa-1.1.0-15.el9.x86_64.rpm"

CHROOT_DIR="${BASE_DIR}/alma9-x86_64"

set -e
echo -e "${yellow}Przygotowuje ${CHROOT_DIR} ${reset}"
echo $URL
rm -fr ${CHROOT_DIR}
mkdir -p $CHROOT_DIR
cd $CHROOT_DIR
wget $URL -o /tmp/wget.log -O - | tar xJf -
cp -a /dev/null /dev/zero /dev/urandom dev/
echo "nameserver 8.8.8.8" > etc/resolv.conf

chroot $CHROOT_DIR dnf --enablerepo=crb install pcsc-lite-devel openssl-devel make gcc libusbx-devel which -y

cd $CHROOT_DIR/tmp
wget -o /tmp/wget.log https://download.videolan.org/pub/videolan/libdvbcsa/1.1.0/libdvbcsa-1.1.0.tar.gz -O - | tar xzf -
chroot $CHROOT_DIR /bin/sh -c "cd /tmp/libdvbcsa-1.1.0; ./configure  --enable-mmx --enable-uint64 --prefix=/usr ; make ; make install ; rm -fr /tmp/libdvbcsa-1.1.0"

chroot $CHROOT_DIR /usr/sbin/adduser -s /bin/sh build
chroot $CHROOT_DIR chmod +wx /home/build

touch ${CHROOT_DIR}/ready
echo -e $green $CHROOT_DIR ready!${reset}

