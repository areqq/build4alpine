#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

ARCHS="x86 x86_64 armv7 aarch64 armhf"
BASE_DIR="/tmp/alpine"
OSCAM_SRC_DIR="${BASE_DIR}/oscam-src"

QEMU="https://github.com/ziglang/qemu-static/releases/download/9.2.0-rc1/qemu-linux-x86_64-9.2.0-rc1.tar.xz"

set -e
unset TMPDIR

ARCH=$(uname -m)
red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
yellow='\033[1;33m'
reset='\033[0m'

if [ ! -d "$OSCAM_SRC_DIR" -o ! -f "${OSCAM_SRC_DIR}/oscam.c" ] ; then
    URL="https://git.streamboard.tv/common/oscam/-/archive/master/oscam-master.tar.gz"
    echo -e "${yellow}Kod oscam pobieram z $URL -> ${OSCAM_SRC_DIR}${reset}" 
    mkdir -p "$OSCAM_SRC_DIR"
    cd "$OSCAM_SRC_DIR"
	wget $URL -o /tmp/wget.log -O - | tar xzf -
    mv oscam-master/* ./
fi

for SETARCH in $ARCHS
do
    if [ "$ARCH" = "x86_64" -a "${SETARCH#x86}" = "$SETARCH" ] ; then
        echo -e ${yellow}Działam na $ARCH do skomilowania $SETARCH potrzebuję qemu + binfmt_misc${reset}

        if [ ! -f ${BASE_DIR}/qemu/bin/qemu-aarch64 ] ; then
            mkdir -p ${BASE_DIR}/qemu
            cd ${BASE_DIR}/qemu
            echo Pobieram: $QEMU
            wget $QEMU -o /tmp/wget.log -O - | tar --strip-components=1 -xJf -
        fi

        if [ ! -d /proc/sys/fs/binfmt_misc ]; then
            echo "No binfmt support in the kernel."
            echo "  Try: '/sbin/modprobe binfmt_misc' from the host"
            exit 1
        fi

        if [ ! -f /proc/sys/fs/binfmt_misc/register ]; then
            mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
        fi

        aarch64="${BASE_DIR}/qemu/bin/qemu-aarch64"
        arm="${BASE_DIR}/qemu/bin/qemu-arm"

        if [ -f /proc/sys/fs/binfmt_misc/register -a ! -f /proc/sys/fs/binfmt_misc/aarch64 ] ; then
            /bin/echo ":aarch64:M::\x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:$aarch64:F" > /proc/sys/fs/binfmt_misc/register 
            /bin/echo ":arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:$arm:F" > /proc/sys/fs/binfmt_misc/register
        fi

        if [ -f /proc/sys/fs/binfmt_misc/aarch64 ] ; then
            echo -e ${green}QEMU skonfigurowane.${reset}
        fi
    fi

    if [ "$ARCH" != "x86_64" -a "${SETARCH#x86}" != "$SETARCH" ] ; then
        echo Buduje na ARM, pomijam $SETARCH
        continue
    fi
    # QEMU setup end

    CHROOT_DIR="${BASE_DIR}/alpine-${SETARCH}"

    if [ ! -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${yellow}Przygotowuje ${CHROOT_DIR} $ALPINE_VER-$SETARCH"
        rm -fr ${CHROOT_DIR}
	    mkdir -p $CHROOT_DIR
	    cd $CHROOT_DIR
        ALPINE_VER=$(wget http://dl-cdn.alpinelinux.org/latest-stable/releases/x86_64/latest-releases.yaml -O - 2> /dev/null | awk '/version:/{v=$2}END{print v}')
        ALPINE_URL="http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$SETARCH/alpine-minirootfs-$ALPINE_VER-$SETARCH.tar.gz"
	    echo Downloadig: $ALPINE_URL
	    wget "$ALPINE_URL" -o /tmp/wget.log -O - | tar xzf - 
	    cp -a /dev/null /dev/zero /dev/urandom dev/
	    echo "nameserver 8.8.8.8" > etc/resolv.conf
	    chroot $CHROOT_DIR /sbin/apk add git openssl-dev libusb-dev pcsc-lite-dev libdvbcsa-dev openssl coreutils build-base linux-headers dialog
	    echo -e "${green}chroot $CHROOT_DIR gotowy! $reset"
    fi 

	cd $CHROOT_DIR
	rm -fr oscam-build-src
    mkdir oscam-build-src
    cp -a ${OSCAM_SRC_DIR}/* oscam-build-src

	chroot "$CHROOT_DIR" /bin/sh -c "cd /oscam-build-src;  make -s allyesconfig; make -s USE_LIBUSB=1 USE_PCSC=1 DEFAULT_PCSC_FLAGS=\"-I/usr/include/PCSC\""
	NEW_BIN=$(ls -t $CHROOT_DIR/oscam-build-src/Distribution/oscam* | head -n1)

	if [ "$NEW_BIN" != "" -a -f "$NEW_BIN" ] ; then
		BIN_NAME=${NEW_BIN##*/}
		mv $NEW_BIN ${BASE_DIR}/${BIN_NAME}
		echo -e ${green}$NEW_BIN${reset}
        BINS="$BINS $BIN_NAME"
	else
		echo "${red}Build error for $SETARCH${reset}"
	fi
done

echo -e ${green}Done.
cd ${BASE_DIR}
for bin in $BINS ; do 
    file $bin 
done

echo -e ${reset}
