#!/bin/bash

export PATH="$HOME/cross/bin:$PATH"
export ARCH="x86_64-w64-mingw32"

(cd $HOME/newlib-cygwin/build && make distclean)
(cd $HOME/newlib-cygwin/ && ./autogen.sh)
(cd $HOME/newlib-cygwin/winsup && ./autogen.sh)

mkdir -p $HOME/newlib-cygwin/build/
cd $HOME/newlib-cygwin/build/

$HOME/newlib-cygwin/configure \
  --host=$ARCH \
  --target=$ARCH \
  --prefix=$HOME/newlib-cygwin/install/ \
  --enable-debugging \
  --disable-doc

make -j$(nproc)
make install
