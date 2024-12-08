#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

. "${0%/*}/vars.conf"

VER=11857

if [ -f $OSCAM_SRC_DIR/oscam.c ] ; then
    echo -e "${red} Juz są źródła w $OSCAM_SRC_DIR, musisz je usunać by popbrać nowe"${reset}
    exit
fi

if [ "$OSCAM_SRC_DIR" != "" ] ; then
    URL="https://git.streamboard.tv/common/oscam/-/archive/${VER}/oscam-$VER.tar.gz"
    echo -e "${yellow}Kod oscam pobieram z $URL -> ${OSCAM_SRC_DIR}${reset}" 
    mkdir -p "$OSCAM_SRC_DIR"
    cd "$OSCAM_SRC_DIR"
    wget $URL -o /tmp/wget.log -O - | tar xzf -
    mv oscam-*/* ./
    echo -e ${green}Finish.${reset}
fi
