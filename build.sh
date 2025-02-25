#!/bin/sh
# vim: tabstop=4 shiftwidth=4 expandtab
# 2024-12 by areq
#
# skrypt bedzie uruchamiany w chroot jako user build

set -e

[ $(id -un) = "root" ] && exit

cd /home/build/
PATH=/bin:/usr/bin:/usr/local/bin

BUILD_ARCH=$(gcc -dumpmachine | awk -F '-' '{print $1}')
echo -e "\033[1;33mBUILD_ARCH: $BUILD_ARCH \033[0m"

#Available options:
#addons: WEBIF WEBIF_LIVELOG WEBIF_JQUERY WITH_COMPRESS_WEBIF WITH_SSL HAVE_DVBAPI WITH_EXTENDED_CW WITH_NEUTRINO READ_SDT_CHARSETS CS_ANTICASC WITH_DEBUG MODULE_MONITOR WITH_LB CS_CACHEEX CS_CACHEEX_AIO CW_CYCLE_CHECK LCDSUPPORT LEDSUPPORT CLOCKFIX IPV6SUPPORT WITH_ARM_NEON WITH_SIGNING
#protocols: MODULE_CAMD33 MODULE_CAMD35 MODULE_CAMD35_TCP MODULE_NEWCAMD MODULE_CCCAM MODULE_CCCSHARE MODULE_GBOX MODULE_RADEGAST MODULE_SCAM MODULE_SERIAL MODULE_CONSTCW MODULE_PANDORA MODULE_GHTTP MODULE_STREAMRELAY
#readers: READER_NAGRA READER_NAGRA_MERLIN READER_IRDETO READER_CONAX READER_CRYPTOWORKS READER_SECA READER_VIACCESS READER_VIDEOGUARD READER_DRE READER_TONGFANG READER_BULCRYPT READER_GRIFFIN READER_DGCRYPT
#card_readers: CARDREADER_PHOENIX CARDREADER_INTERNAL CARDREADER_SC8IN1 CARDREADER_MP35 CARDREADER_SMARGO CARDREADER_DB2COM CARDREADER_STAPI CARDREADER_STAPI5 CARDREADER_STINGER CARDREADER_DRECAS

sed -i 's/@$(GIT_SHA)//' Makefile
sed -i 's/#define CS_VERSION[[:space:]]*"\([^"-]*\)-/#define CS_VERSION   "AQQQ-/' globals.h

./config.sh --enable all --disable LCDSUPPORT LEDSUPPORT CLOCKFIX HAVE_DVBAPI  MODULE_CAMD33 MODULE_SCAM MODULE_SERIAL MODULE_GHTTP MODULE_PANDORA READER_DRE CARDREADER_DB2COM CARDREADER_STAPI CARDREADER_STAPI5 CARDREADER_DRECAS IPV6SUPPORT MODULE_STREAMRELAY WITH_ARM_NEON

STATIC='EXTRA_FLAGS=-static EXTRA_TARGET=-static LIBUSB_LIB=/usr/lib/libusb-1.0.a LIBCRYPTO_LIB=/usr/lib/libcrypto.a SSL_LIB=/usr/lib/libssl.a PCSC_LIB=/usr/lib/libpcsclite.a'

#tylko dla aarch64 buduj podstawową wersje z ARM_NEON
[ "$BUILD_ARCH" = "aarch64" ] && ./config.sh --enable WITH_ARM_NEON

make USE_LIBUSB=1 USE_PCSC=1 DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" CONF_DIR=/etc/oscam

if [ -f /usr/lib/libusb-1.0.a -a -f /usr/lib/libcrypto.a -a -f /usr/lib/libssl.a -a -f /usr/lib/libpcsclite.a ] ; then
    make USE_LIBUSB=1 USE_PCSC=1 DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" CONF_DIR=/etc/oscam $STATIC
else
    echo "$red Brakuje statycznych libów. Omijam budowanie -static $reset"
fi

#if [ "$BUILD_ARCH" = "armhf" -o "$BUILD_ARCH" = "armv7" -o "$BUILD_ARCH" = "armv6" ]; then
#    ./config.sh --enable WITH_ARM_NEON
#    make USE_LIBUSB=1 USE_PCSC=1 DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" CONF_DIR=/etc/oscam EXTRA_TARGET="-neon"
#    make USE_LIBUSB=1 USE_PCSC=1 DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" CONF_DIR=/etc/oscam $STATIC EXTRA_TARGET="-neon-static"
#fi


ls -t $CHROOT_DIR/home/build/Distribution/oscam* | grep -v '\.debug$' | while read f
do
    cp -a "$f" /home/build/output/
    ldd "$f"
done

