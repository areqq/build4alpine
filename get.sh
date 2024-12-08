#!/bin/sh
URL="https://raw.githubusercontent.com/areqq/build4alpine/refs/heads/main/"

mkdir -p build4alpine
for plik in build-all.sh build-in-chroot.sh build.sh setup-chroots-alma.sh setup-chroots-alpine.sh setup-qemu.sh update-oscam-from-git.sh vars.conf
do
    echo Pobieram $plik do build4alpine/
    wget -o /tmp/wget.log $URL/$plik -O -> build4alpine/$plik
done
chmod +x build4alpine/*.sh


