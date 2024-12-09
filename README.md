# build4alpine

Zestaw skrytów pomocniczych w budowaniu w chroot na różne systemy i architektury na przykładzie oscam.

Konfiguracja w vars.conf
```
BASE_DIR - katalog w którym będą zainstalowane dystrybucje
OSCAM_SRC_DIR - katalog ze źródłami do kompilacji
OUTPUT_BIN_DIR - gdzie zapisać wynikowe pliki
```

Chroot zawieraja minimaly system + biblioteki do poprawnego zbudowania pełnej wersji oscam.
Budowanie będzie odbywać się z usera build w jego /home/build

# Howto
```
./setup-chroots-alpine.sh - przygotuje katalogi z chroot dla wskazanych architekur
./setup-chroots-alma.sh - możemy też mieć buildy dla AlmaLinux 9 x64
./update-oscam-from-git.sh - pobiera, źródła do kompilacji - możesz je podmienić na swoje w katalogu OSCAM_SRC_DIR
```
Ustaw parametry budowania w build.sh

Zbudowanie na jeden system
```
./build-in-chroot.sh alpine-x86 /tmp/alpine/oscam-src ./build.sh

./build-all.sh  - buduje na wszystkich dostępnych chroot
```

# QEMU

Jest możliwość budowania pod arm/aarch64 za pomocą QEMU. Nie jest szybkie, ale w kilka minut się zbuduje.
```
./setup-qemu.sh  - Pobierze i skonfiguruje QEMU
```
# Natywne budowane na ARM

Można zrobic to np na VU+ uno4kse z dyskiem ;) Albo na innym Raspberry Pi
```
mkdir -p /hdd/aq/alpine
cd /hdd/aq/alpine
wget https://raw.githubusercontent.com/areqq/build4alpine/refs/heads/main/get.sh -O - | sh

cd build4alpine

w vars.conf ustawiamy:
BASE_DIR="/hdd/aq/alpine"

./update-oscam-from-git.sh - pobieramy źródła oscam z git
./setup-chroots-alpine.sh armv7  - przygotuje nam chroot dla armv7 w /hdd/aq/alpine/alpine-armv7

./build-all.sh - uruchamiamy budowanie
```

Po kilku minutach:
```
oscam-2.24.12-11857@-armv7-alpine-linux-musleabihf-ssl-libusb-pcsc-libdvbcsa saved in /hdd/aq/alpine/bins
```
