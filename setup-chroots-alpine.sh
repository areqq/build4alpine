#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

. "${0%/*}/vars.conf"

ALL_ARCHS="x86 x86_64 armv7 aarch64 armhf"

if [ $# -eq 0 ]; then
    echo $0 - Build Alpine Linux chroot in ${BASE_DIR}
    echo Example:
    echo $0 x86 x86_64   - create chroot for x86 and x86_64 arch
    echo $0 all          - create chroots for $ALL_ARCHS
    exit
fi

if [ "$1" = "all" ] ; then
    ARCHS=$ALL_ARCHS
else
    ARCHS=$@
fi

ALPINE_VER=$(wget http://dl-cdn.alpinelinux.org/latest-stable/releases/x86_64/latest-releases.yaml -O - 2> /dev/null | awk '/version:/{v=$2}END{print v}')

for SETARCH in $ARCHS
do
    CHROOT_DIR="${BASE_DIR}/alpine-${SETARCH}"

    if [ ! -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${yellow}Przygotowuje ${CHROOT_DIR} $ALPINE_VER-$SETARCH"
        rm -fr ${CHROOT_DIR}
        mkdir -p $CHROOT_DIR
        cd $CHROOT_DIR
        ALPINE_URL="http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$SETARCH/alpine-minirootfs-$ALPINE_VER-$SETARCH.tar.gz"
        echo Downloadig: $ALPINE_URL
        wget "$ALPINE_URL" -o /tmp/wget.log -O - | tar xzf - 

        cp -a /dev/null /dev/zero /dev/urandom dev/
        echo "nameserver 8.8.8.8" > etc/resolv.conf

        chroot $CHROOT_DIR /sbin/apk add openssl-dev openssl-libs-static libusb-dev pcsc-lite-dev pcsc-lite-static openssl coreutils build-base linux-headers dialog
        chroot $CHROOT_DIR /usr/sbin/adduser -D -s /bin/sh build
        chroot $CHROOT_DIR chmod +wx /home/build
    fi 

    if [ -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${green}chroot $CHROOT_DIR gotowy! $reset"
        touch ${CHROOT_DIR}/ready
    else
        echo -e "${red}chroot $CHROOT_DIR - problem z instalacją! $reset"
    fi

done

echo -e ${reset}
