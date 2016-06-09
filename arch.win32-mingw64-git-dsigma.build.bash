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

    rm -rf libusb-1.0.20 dfu-util-dsigma-git libusb-1.0.20.tar.bz2

}

copylibs () {
    CROSS_COMPILE_PREFIX=i686-w64-mingw32

    CROSS_GCC_VERSION=$(${CROSS_COMPILE_PREFIX}-gcc --version | grep 'gcc' | sed -e 's/.*\s\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\).*/\1.\2.\3/')
    CROSS_GCC_VERSION_SHORT=$(echo $CROSS_GCC_VERSION | sed -e 's/\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\).*/\1.\2/')
    if [ -f "/usr/lib/gcc/${CROSS_COMPILE_PREFIX}/${CROSS_GCC_VERSION}/libgcc_s_sjlj-1.dll" ]
    then
      cp -v "/usr/lib/gcc/${CROSS_COMPILE_PREFIX}/${CROSS_GCC_VERSION}/libgcc_s_sjlj-1.dll" \
        "$1/bin"
    elif [ -f "/usr/lib/gcc/${CROSS_COMPILE_PREFIX}/${CROSS_GCC_VERSION_SHORT}/libgcc_s_sjlj-1.dll" ]
    then
      cp -v "/usr/lib/gcc/${CROSS_COMPILE_PREFIX}/${CROSS_GCC_VERSION_SHORT}/libgcc_s_sjlj-1.dll" \
        "$1/bin"
    else
      echo "Searching /usr for libgcc_s_sjlj-1.dll..."
      SJLJ_PATH=$(find /usr \! -readable -prune -o -name 'libgcc_s_sjlj-1.dll' -print | grep ${CROSS_COMPILE_PREFIX})
      cp -v ${SJLJ_PATH} "$1/bin"
    fi

    if [ -f "/usr/${CROSS_COMPILE_PREFIX}/lib/libwinpthread-1.dll" ]
    then
      cp "/usr/${CROSS_COMPILE_PREFIX}/lib/libwinpthread-1.dll" \
        "$1/bin"
    else
      echo "Searching /usr for libwinpthread-1.dll..."
      PTHREAD_PATH=$(find /usr \! -readable -prune -o -name 'libwinpthread-1.dll' -print | grep ${CROSS_COMPILE_PREFIX})
      cp -v "${PTHREAD_PATH}" "$1/bin"
    fi

}

clean

set -e

WORK_DIR=$PWD
BUILD_DIR=$PWD/dfu-util-build-dsigma

MINGW_VERSION=i686-w64-mingw32

[ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
# cd $BUILD_DIR

# get libusb sources
[ -d libusb-1.0.20 ] || { wget -O libusb-1.0.20.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.20/libusb-1.0.20.tar.bz2/download && tar jxvf libusb-1.0.20.tar.bz2 ;}
cd libusb-1.0.20
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR
# WINVER workaround needed for 1.0.20 only
# make CFLAGS="-DWINVER=0x0501"
make
make install
cd $WORK_DIR

tag=`git rev-parse --short HEAD`

# get dfu-util sources
[ ! -d dfu-util-dsigma-git ] && git clone https://github.com/dsigma/dfu-util.git dfu-util-dsigma-git
cd dfu-util-dsigma-git
./autogen.sh
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --host=$MINGW_VERSION --prefix=$BUILD_DIR
make
make install
cd $WORK_DIR

copylibs $BUILD_DIR

cp launchers/win/StAr_Write.bat $BUILD_DIR/bin

mv dfu-util-build-dsigma/ dfu-util/

tar cvf dfu-util-dsigma-win32-mingw64-$tag.tar.gz dfu-util/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util/

clean
