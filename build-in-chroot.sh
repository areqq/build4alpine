#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
#
# 2024-12 by areq
set -e

. "${0%/*}/vars.conf"

if [ "$#" -ne 3 ]; then
echo ---------------------------------------------
echo $0 - Kompilacja oscam w chroot
echo Parametry:
echo  chroot_dir - nazwa chroot
echo     src_dir - pełna ścieżka do źródeł
echo    build.sh - ścieżka do skryptu który się uruchomi w chroot w katalogu ze żródłami
echo
echo Przykład:
echo $0 alpine-x86 $OSCAM_SRC_DIR ${0%/*}/build.sh
exit
fi

CHROOT_DIR=${BASE_DIR}/$1
SRC_DIR=$(readlink -f $2)
BUILD_SH=$(readlink -f $3)

echo -e "${green}Started.${reset}"
echo -e "${yellow}chroot_dir:${reset} $CHROOT_DIR"
echo -e "${yellow}   src_dir:${reset} $SRC_DIR"
echo -e "${yellow}  build.sh:${reset} $BUILD_SH"
echo


if [ "$CHROOT_DIR" = "" -o ! -d "$CHROOT_DIR" -o ! -d "$CHROOT_DIR/home/build" ] ; then
    echo "${red} chroot_dir: $CHROOT_DIR - not found.${reset}"
    exit 1
fi

if [ "$SRC_DIR" = "" -o ! -d "$SRC_DIR" -o ! -f $SRC_DIR/oscam.c ] ; then
    echo "${red} src_dir: $SRC_DIR - not found.${reset}"
    exit 1
fi

if [ "$BUILD_SH" = "" -o ! -f "$BUILD_SH" ] ; then
    echo "${red} build.sh: $BUILD_SH - not found.${reset}"
    exit 1
fi

cd $CHROOT_DIR
rm -fr home/build/*
cp -a ${SRC_DIR}/* home/build/
mkdir -p home/build/output/
cp $BUILD_SH home/build/go.sh
chroot "$CHROOT_DIR" chown -R build /home/build/

echo -e ${green}Rozpoczynam kompilacje${reset}
chroot "$CHROOT_DIR" /bin/su -l build -c "cd /home/build; /bin/sh ./go.sh"

find $CHROOT_DIR/home/build/output -type f | while read NEW_BIN
do
    BIN_NAME=${NEW_BIN##*/}
    mkdir -p ${OUTPUT_BIN_DIR}
	mv $NEW_BIN ${OUTPUT_BIN_DIR}/${BIN_NAME}
	echo -e ${green}$BIN_NAME saved in ${OUTPUT_BIN_DIR} ${reset}
done

