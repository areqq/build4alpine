#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

#  Pobiera statyczne wersje qemu do aarch64 arm 
#  konfiguruje obsługe binarek arm przez infmt_misc - Zawsze po reestarcie trzeba zrobić

set -e

. "${0%/*}/vars.conf"

if [ "$ARCH" != "x86_64" ] ; then
    echo -e ${red}QEMU potrzebujesz tylko na x86_64${reset}
    exit
fi

if [ "$BASE_DIR" != "" -a -d "$BASE_DIR" ] ; then

    cd $BASE_DIR

    aarch64="${BASE_DIR}/qemu/bin/qemu-aarch64"
    arm="${BASE_DIR}/qemu/bin/qemu-arm"

    mkdir -p qemu/bin

    if [ ! -f $aarch64 ] ; then
        echo -e ${yellow}Działam na $ARCH do skomilowania $SETARCH potrzebuję qemu + binfmt_misc${reset}
        rm -fr ${BASE_DIR}/qemu
        mkdir -p ${BASE_DIR}/qemu
        cd ${BASE_DIR}/qemu
        echo Pobieram: $QEMU
        wget $QEMU -o /tmp/wget.log -O - | tar --strip-components=1 -xJf -
    fi

    if [ -f $aarch64 -a -f $arm ] ; then
        echo -e ${green}QEMU pobrane.${reset}
    else
        echo -e ${red}Problem z pobraniem QEMU.${reset}
        exit 1
    fi

    if [ ! -d /proc/sys/fs/binfmt_misc ]; then
        echo -e ${red}"No binfmt support in the kernel."
        echo -e "  Try: '/sbin/modprobe binfmt_misc' from the host${reset}"
        exit 1
    fi

    if [ ! -f /proc/sys/fs/binfmt_misc/register ]; then
        mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    fi

    if [ -f /proc/sys/fs/binfmt_misc/register ]; then
        [ -f /proc/sys/fs/binfmt_misc/aarch64 ] && echo -1 > /proc/sys/fs/binfmt_misc/aarch64
        [ -f /proc/sys/fs/binfmt_misc/arm ] && echo -1 > /proc/sys/fs/binfmt_misc/arm
        /bin/echo ":aarch64:M::\x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:$aarch64:F" > /proc/sys/fs/binfmt_misc/register 
        /bin/echo ":arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:$arm:F" > /proc/sys/fs/binfmt_misc/register
    else
        echo -e ${red}Problem binfmt nie skonfigurowane. Brak /proc/sys/fs/binfmt_misc/register${reset}
    fi

    if [ -f /proc/sys/fs/binfmt_misc/aarch64 ] ; then
        echo -e ${green}QEMU binfmt skonfigurowane.${reset}
    else
        echo -e ${red}Problem binfmt nie skonfigurowane.${reset}
    fi

else
    echo -e ${red}Problem QEMU nie skonfigurowane. Coś nie tak z BASE_DIR: $BASE_DIR${reset}
fi

