#!/bin/bash

#
# The dfu-util binaries for Windows (win32) were
# built on Debian using this build script.
#
# To install needed build dependencies run:
#  sudo apt-get build-dep libusb-1.0-0 dfu-util
#  sudo apt-get install gcc-mingw-w64-i686 g++-mingw-w64-i686
#

clean() {

    rm -rf libusb-1.0.21 dfu-util-dsigma-git libusb-1.0.21.tar.bz2

}

clean

set -e

WORK_DIR=$PWD
BUILD_DIR=$PWD/dfu-util-build-dsigma

MINGW_VERSION=i686-w64-mingw32

[ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
# cd $BUILD_DIR

# get libusb sources
[ -d libusb-1.0.21 ] || { wget -O libusb-1.0.21.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.21/libusb-1.0.21.tar.bz2/download && tar jxvf libusb-1.0.21.tar.bz2 ;}
cd libusb-1.0.21
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR --enable-static --disable-shared
# WINVER workaround needed for 1.0.21 only
# make CFLAGS="-DWINVER=0x0501"
make
make install
cd $WORK_DIR

tag=`git rev-parse --short HEAD`

# get dfu-util sources
[ ! -d dfu-util-dsigma-git ] && git clone https://github.com/artynet/dfu-util-official.git dfu-util-dsigma-git
cd dfu-util-dsigma-git
./autogen.sh
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR \
            USB_CFLAGS="-I$BUILD_DIR/include/libusb-1.0" \
            USB_LIBS="-L$BUILD_DIR/lib -lusb-1.0" PKG_CONFIG=true
make LDFLAGS=-static
make install
cd $WORK_DIR

cp $WORK_DIR/launchers/win/StAr_Write.bat $BUILD_DIR/bin

mv dfu-util-build-dsigma/ dfu-util/

tar cvf dfu-util-dsigma-win32-mingw64-$tag.tar.gz dfu-util/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util/

clean
