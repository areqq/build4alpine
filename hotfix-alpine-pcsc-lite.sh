#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq
set -e

. "${0%/*}/vars.conf"

fix_chroot()
{
    CHROOT="$1"

    if [ -f $CHROOT/etc/alpine-release ] ; then

        if [ -f $CHROOT/usr/include/PCSC/pcsclite.h ] ; then 
            PCSCLITE_VERSION=$(awk -F '"' '/PCSCLITE_VERSION_NUMBER/{print $2}' $CHROOT/usr/include/PCSC/pcsclite.h)
            if [ "$PCSCLITE_VERSION" = "2.3.1" ] ; then
                echo -e "${green}OK: $CHROOT pcsc-lite already downgraded PCSCLITE_VERSION: $PCSCLITE_VERSION $reset"
                return
            else
                echo -e "${yellow}$CHROOT pcsc-lite wrong PCSCLITE_VERSION: $PCSCLITE_VERSION $reset"
            fi
        fi

        ARCH=$(cat $CHROOT/etc/apk/arch)
        REPO="https://dl-cdn.alpinelinux.org/alpine/edge/main/$ARCH/"
        echo -e $green --- $CHROOT --- $reset
        echo -e REPO: $REPO

        rm -f $CHROOT/tmp/pcsc-lite-*.apk

        for pkg in $PCSC_PKGS
        do
            APK="${pkg}-2.3.1-r0.apk"
            wget -o /dev/null "${REPO}${APK}" -O $CHROOT/tmp/${APK}
        done

        chroot $CHROOT /sbin/apk del $PCSC_PKGS
        chroot $CHROOT /bin/sh -c "cd /tmp/; /sbin/apk add pcsc-lite-*.apk"

        PCSCLITE_VERSION=$(awk -F '"' '/PCSCLITE_VERSION_NUMBER/{print $2}' $CHROOT/usr/include/PCSC/pcsclite.h)

        if [ "$PCSCLITE_VERSION" = "2.3.1" ] ; then
            echo -e "$green${CHROOT} pcsc-lite reinstalled successfully PCSCLITE_VERSION: $PCSCLITE_VERSION $reset"
        else
            echo -e "$red${CHROOT} pcsc-lite reinstall problem: PCSCLITE_VERSION: $PCSCLITE_VERSION $reset"
        fi

        echo -e $reset
        rm -f $CHROOT/tmp/pcsc-lite-*.apk
    else
        echo "$CHROOT - ignored"
    fi
}

PCSC_PKGS="pcsc-lite-dev pcsc-lite-libs pcsc-lite-spy-libs pcsc-lite-static "

ls $BASE_DIR/*-*/ready | while read r
do  
    DIR=${r%/ready}
    fix_chroot $DIR
done

# pcsc-lite > 2.0.3 has problem with static build, so we need downgrade or upgrade to 2.3.1
