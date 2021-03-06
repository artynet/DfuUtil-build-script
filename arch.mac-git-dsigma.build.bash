#!/bin/bash

export CFLAGS="-arch x86_64 -arch i386 -mmacosx-version-min=10.5"
export CXXFLAGS="-arch x86_64 -arch i386 -mmacosx-version-min=10.5"
export LDFLAGS="-arch x86_64 -arch i386"

clean() {

    rm -rf libusb-1.0.21/ dfu-util-0.8/ dfu-util-0.8.tar.gz dfu-util-dsigma-git/

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
USBBUILD=$PWD/libusb-build
DFUBUILD=$PWD/dfu-util-build

mkdir -p $BUILD_DIR
mkdir -p $USBBUILD
mkdir -p $DFUBUILD
# cd $BUILD_DIR

# get libusb sources
if [ ! -f libusb-1.0.21.tar.bz2 ]
then
    wget -O libusb-1.0.21.tar.bz2 http://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.21/libusb-1.0.21.tar.bz2/download
fi

tar jxvf libusb-1.0.21.tar.bz2

cd $USBBUILD
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ../libusb-1.0.21/configure --prefix=$BUILD_DIR --enable-static --disable-shared
# WINVER workaround needed for 1.0.19 only
# make CFLAGS="-DWINVER=0x0501"
make
make install
cd $WORK_DIR

tag=`git rev-parse --short HEAD`

# get dfu-util sources
[ ! -d dfu-util-dsigma-git ] && git clone https://github.com/artynet/dfu-util-official.git dfu-util-dsigma-git
cd dfu-util-dsigma-git
./autogen.sh
cd $DFUBUILD
PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig ../dfu-util-dsigma-git/configure --prefix=$BUILD_DIR \
            USB_CFLAGS="-I$BUILD_DIR/include/libusb-1.0  -framework IOKit -framework CoreFoundation" \
            USB_LIBS="-L$BUILD_DIR/lib -lusb-1.0" PKG_CONFIG=true
make
make install

cd $BUILD_DIR/bin

# renameexe

cd $WORK_DIR

mv dfu-util-build-dsigma/ dfu-util/

tar cvf dfu-util-dsigma-osx-$tag.tar.gz dfu-util/

echo ""
echo "Cleaning...."
echo ""

rm -rf dfu-util/

clean
