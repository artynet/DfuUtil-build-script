#!/bin/bash

export CFLAGS="-arch x86_64 -arch i386 -mmacosx-version-min=10.5"
export CXXFLAGS="-arch x86_64 -arch i386 -mmacosx-version-min=10.5"
export LDFLAGS="-arch x86_64 -arch i386"

clean() {

    rm -rf libusb-1.0.20 dfu-util-0.8 dfu-util-0.8.tar.gz libusb-1.0.20.tar.bz2

}

renameexe () {

    for i in dfu-util dfu-suffix dfu-prefix
    do
        mv $i $i-bin
        cp $WORK_DIR/launchers/mac/$i .
    done

}

clean

set -e

#ARCH=`uname -s`
WORK_DIR=$PWD
BUILD_DIR=$PWD/dfu-util-build-dsigma

[ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
# cd $BUILD_DIR

# get libusb sources
[ -d libusb-1.0.20 ] || { wget -O libusb-1.0.20.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.20/libusb-1.0.20.tar.bz2/download && tar jxvf libusb-1.0.20.tar.bz2 ;}
cd libusb-1.0.20
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --prefix=$BUILD_DIR
# WINVER workaround needed for 1.0.19 only
# make CFLAGS="-DWINVER=0x0501"
make
make install
cd $WORK_DIR

# get dfu-util sources
[ ! -d dfu-util-dsigma-git ] && git clone https://github.com/dsigma/dfu-util.git dfu-util-dsigma-git
cd dfu-util-dsigma-git
tag=`git rev-parse --short HEAD`
./autogen.sh
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ./configure --prefix=$BUILD_DIR USB_CFLAGS="-I$BUILD_DIR/include/libusb-1.0" \
            USB_LIBS="-L $BUILD_DIR/lib -lusb-1.0" PKG_CONFIG=true
make
make install

cd $BUILD_DIR/bin

renameexe

cd $WORK_DIR

mv dfu-util-build-dsigma/ dfu-util/

tar cvf dfu-util-dsigma-osx-$tag.tar.gz dfu-util/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util/

clean
