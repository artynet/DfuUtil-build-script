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
BUILD_DIR=$PWD/dfu-util-build

# MINGW_VERSION=i686-w64-mingw32
MINGW_VERSION=i586-mingw32msvc

[ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
# cd $BUILD_DIR

# get libusb sources
[ -d libusb-1.0.19 ] || { wget -O libusb-1.0.19.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.19/libusb-1.0.19.tar.bz2/download && tar jxvf libusb-1.0.19.tar.bz2 ;}
cd libusb-1.0.19
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --prefix=$BUILD_DIR --host=$MINGW_VERSION
# PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./autogen.sh --host=$MINGW_VERSION --prefix=$BUILD_DIR
# WINVER workaround needed for 1.0.19 only
make CFLAGS="-DWINVER=0x0501"
make
make install
make distclean
git reset --hard HEAD
cd $WORK_DIR

tag=`git rev-parse --short HEAD`

MINGW_VERSION=i586-mingw32msvc

# get dfu-util sources
[ ! -d dfu-util-git ] && git clone git://git.code.sf.net/p/dfu-util/dfu-util dfu-util-git
cd dfu-util-git
./autogen.sh
#PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --prefix=$BUILD_DIR USB_CFLAGS="-I$BUILD_DIR/include/libusb-1.0" \
            # USB_LIBS="-L $BUILD_DIR/lib -lusb-1.0" PKG_CONFIG=true
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR
# make LDFLAGS=-static
make
make install
make distclean
git reset --hard HEAD
cd $WORK_DIR

mv dfu-util-build/ dfu-util-$tag-win32/

zip -r dfu-util-$tag-win32.zip dfu-util-$tag-win32/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util-$tag-win32/

clean
