export CFLAGS="-Wno-error=overloaded-virtual -Wno-error=narrowing -Wno-error=use-after-free -Wno-error=address"
export CPPFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS

(cd /cygdrive/c/Projekty/newlib-cygwin/winsup && ./autogen.sh)

cd /cygdrive/c/Projekty/newlib-cygwin/build/

/cygdrive/c/Projekty/newlib-cygwin/configure \
  --prefix=/cygdrive/c/Projekty/newlib-cygwin/install/ \
  --disable-doc \
  --enable-debugging

make
make install
