#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

. "${0%/*}/vars.conf"

VER="15.x"
ALL_ARCHS="x86"

if [ $# -eq 0 ]; then
    echo $0 - Build Tiny Core Linux $VER chroot in ${BASE_DIR}
    echo Example:
    echo $0 x86          - create chroot for x86 
    echo $0 all          - create chroots for $ALL_ARCHS
    exit
fi

if [ "$1" = "all" ] ; then
    ARCHS=$ALL_ARCHS
else
    ARCHS=$@
fi

if ! unsquashfs -v 2>&1 | grep -q version ; then
    echo "$red unsquashfs not found, install squashfs or squashfs-tools package $restet"
    exit 1
fi

for SETARCH in $ARCHS
do
    if ! echo $ALL_ARCHS | grep -q $SETARCH ; then
        echo $red Nie obsługuję architektury: $SETARCH
        continue 
    fi

    CHROOT_DIR="${BASE_DIR}/tinycorelinux-${SETARCH}"

    if [ ! -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${yellow}Przygotowuje ${CHROOT_DIR} $VER-$SETARCH"
        rm -fr ${CHROOT_DIR}
        mkdir -p $CHROOT_DIR
        cd $CHROOT_DIR
        URL="http://tinycorelinux.net/${VER}/${SETARCH}/release/distribution_files/rootfs.gz"
        echo Downloadig: $URL
        wget "$URL" -o /tmp/wget.log -O - | gzip -dc | cpio -id

        cp -a /dev/null /dev/zero /dev/urandom dev/
        echo "nameserver 8.8.8.8" > etc/resolv.conf

        for pkg in gcc make openssl openssl-dev libusb libusb-dev pcsc-lite pcsc-lite-dev coreutils isl mpc gcc_libs mpfr gmp libzstd linux-6.6_api_headers glibc_base-dev binutils udev-lib udev-dev 
        do
            URL="http://tinycorelinux.net/${VER}/${SETARCH}/tcz/${pkg}.tcz"
            wget "$URL" -o /tmp/wget.log -O $pkg.tcz
            echo -n "$pkg "
            unsquashfs -q -n -f -d ./ $pkg.tcz
            rm $pkg.tcz
        done
        echo

        mv usr/local/include/PCSC usr/include
        rm bin/date
        ln -s ../usr/local/bin/date bin/date
        echo > etc/init.d/tc-functions
        echo > etc/sysconfig/tcuser

        chroot $CHROOT_DIR /usr/sbin/adduser -D -s /bin/sh build
        chroot $CHROOT_DIR chmod +wx /home/build
        chroot $CHROOT_DIR ldconfig
    fi 

    if [ -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${green}chroot gotowy! $(du -sh $CHROOT_DIR) $reset"
        touch ${CHROOT_DIR}/ready
    else
        echo -e "${red}chroot $CHROOT_DIR - problem z instalacją! $reset"
    fi

done

echo -e ${reset}
