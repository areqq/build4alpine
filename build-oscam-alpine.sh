#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq

. "${0%/*}/vars.conf"

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

    CHROOT_DIR="${BASE_DIR}/alpine-${SETARCH}"

    if [ ! -d "${CHROOT_DIR}/usr/include/PCSC" ] ; then
        echo -e "${red} Brak ${CHROOT_DIR} $ALPINE_VER-$SETARCH"
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
