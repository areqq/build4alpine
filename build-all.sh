#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq
set -e

. "${0%/*}/vars.conf"

MYDIR=$(readlink -f ${0%/*})

ls $BASE_DIR/*-*/ready | while read r
do  
    CHROOT=${r%/ready}
    CHROOT=${CHROOT##*/}
    cd $MYDIR
    echo -e $green --- $CHROOT --- $reset
    ./build-in-chroot.sh $CHROOT $OSCAM_SRC_DIR ./build.sh
done
