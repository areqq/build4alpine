# build4alpine

Zestaw skrytów pomocniczych w budowaniu w chroot na różne systemy i architektury na przykładzie oscam.

Konfiguracja w vars.conf - zaznacz tam architektury które Cię interesują.

Chroot zawieraja minimaly system + biblioteki do poprawnego znbudowania pełnej wersji oscam.
Budowanie będzie odbywać się z usera build w jego /home/build
Wynikowe pliki binarne zapiszą się w OUTPUT_BIN_DIR

# Howto

./setup-chroots-alpine.sh - przygotuje katalogi z chroot dla wskazanych w vars.conf architektur
./setup-chroots-alma.sh - możemy też mieć buildy dla AlmaLinux 9 x64
./update-oscam-from-git.sh - pobiera, źródła do kompilacji - możesz je podmienić na swoje w katalogu OSCAM_SRC_DIR

Ustaw parametry budowania w build.sh

Zbudowanie na jeden system
./build-in-chroot.sh alpine-x86 /tmp/alpine/oscam-src ./build.sh

./build-all.sh  - buduje na wszystkich dostępnych chroot


#QEMU

Jest możliwość budowania pod arm/aarch64 za pomocą QEMU. Nie jest szybkie, ale w kilka minut się zbuduje.

./setup-qemu.sh  - Pobierze i skonfiguruje QEMU
