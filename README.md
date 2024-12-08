# build4alpine

Zestaw skrytów pomocniczych w budowaniu w chroot na różne systemy i architektury na przykładzie oscam.

Konfiguracja w vars.conf - zaznacz tam architektury które Cię interesują.

# Howto

./setup-chroots-alpine.sh - przygotuje katalogi z chroot dla wskazanych w vars.conf architektur
./setup-chroots-alma.sh - możeny też mieć buildy dla AlmaLinux 9 x64
./update-oscam-from-git.sh - pobiera, źródła do kompilacji - możesz je podmienić na swoje w katalogu OSCAM_SRC_DIR

ustaw paramtery budowania w build.sh

Zbudowanie na jeden system
./build-in-chroot.sh alpine-x86 /tmp/alpine/oscam-src ./build.sh

./build-all.sh  - buduje na wszystkich 
