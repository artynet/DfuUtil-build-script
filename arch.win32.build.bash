#!/bin/bash

#
# The dfu-util binaries for Windows (win32) were
# built on Debian using this build script.
#
# To install needed build dependencies run:
#  sudo apt-get build-dep libusb-1.0-0 dfu-util
#  sudo apt-get install mingw32
#

clean() {

    rm -rf libusb-1.0.19 dfu-util-0.8 dfu-util-0.8.tar.gz libusb-1.0.19.tar.bz2

}

clean

set -e

WORK_DIR=$PWD
BUILD_DIR=$PWD/dfu-util-build-win32

MINGW_VERSION=i586-mingw32msvc

[ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
# cd $BUILD_DIR

# get libusb sources
[ -d libusb-1.0.19 ] || { wget -O libusb-1.0.19.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.19/libusb-1.0.19.tar.bz2/download && tar jxvf libusb-1.0.19.tar.bz2 ;}
cd libusb-1.0.19
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR
# WINVER workaround needed for 1.0.19 only
make CFLAGS="-DWINVER=0x0501"
make
make install
cd $WORK_DIR

# get dfu-util sources
[ -d dfu-util-0.8 ] || { wget http://dfu-util.gnumonks.org/releases/dfu-util-0.8.tar.gz && tar zxvf dfu-util-0.8.tar.gz ;}
cd dfu-util-0.8
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR
make LDFLAGS=-static
make install
cd $WORK_DIR

mv dfu-util-build-win32/ dfu-util-0.8-win32/

zip -r dfu-util-0.8-win32.zip dfu-util-0.8-win32/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util-0.8-win32/

clean
