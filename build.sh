#!/bin/bash

PATH="$HOME/cross/bin:$PATH"
BUILD="x86_64-pc-cygwin"
TARGET="x86_64-w64-mingw32"

(cd $HOME/newlib-cygwin/build && make distclean)
(cd $HOME/newlib-cygwin/ && ./autogen.sh)
(cd $HOME/newlib-cygwin/winsup && ./autogen.sh)

mkdir -p $HOME/newlib-cygwin/build/
cd $HOME/newlib-cygwin/build/

# "echo | gcc -dM -E -" vs "echo | x86_64-w64-mingw32-gcc -dM -E -"
MY_DEFINES=" \
  -D__unix=1 -D__unix__=1 -Dunix=1 -D__LP64__=1 -D_LP64=1 -D__CYGWIN__=1 \
  -U__MINGW32__ -U__MINGW64__ -U_REENTRANT -U__WINNT__ -U__WINNT -UWINNT \
  -U__WIN64__ -U_WIN64 -U__WIN64 -UWIN64 \
  -U__WIN32__ -U_WIN32 -U__WIN32 -UWIN32 \
  -U__MSVCRT__ -U_INTEGRAL_MAX_BITS \
  -U__WINT_TYPE__ -D__WINT_TYPE__=unsigned \
  -U__WINT_WIDTH__ -D__WINT_WIDTH__=32 \
  -U__WINT_MIN__ -D__WINT_MIN__=0U \
  -U__WINT_MAX__ -D__WINT_MAX__=0xffffffffU \
  `# -U__SIZE_TYPE__ -D'__SIZE_TYPE__=long unsigned int'` \
  -U__SIZE_MAX__ -D__SIZE_MAX__=0xffffffffffffffffUL \
  -U__SIZEOF_LONG__ -D__SIZEOF_LONG__=8 \
  -U__SIZEOF_INT128__ -D__SIZEOF_INT128__=16 \
  -U__SIZEOF_WINT_T__ -D__SIZEOF_WINT_T__=4 \
  -U__INT_FAST16_TYPE__ -D__INT_FAST16_TYPE__=long \
  -U__INT_FAST16_WIDTH__ -D__INT_FAST16_WIDTH__=64 \
  -U__INT_FAST16_MAX__ -D__INT_FAST16_MAX__=0x7fffffffffffffffL \
  -U__INT_FAST32_TYPE__ -D__INT_FAST32_TYPE__=long \
  -U__INT_FAST32_MAX__ -D__INT_FAST32_MAX__=0x7fffffffffffffffL \
  -U__INT_FAST64_TYPE__ -D__INT_FAST64_TYPE__=long \
  -U__INT_FAST64_MAX__ -D__INT_FAST64_MAX__=0x7fffffffffffffffL \
  -U__INT_LEAST64_MAX__ -D__INT_LEAST64_MAX__=0x7fffffffffffffffL \
  -U__INT64_TYPE__ -D__INT64_TYPE__=long \
  -U__INT64_C `# -D'__INT64_C(c)=c ## L'` \
  -U__INTMAX_TYPE__ -D__INTMAX_TYPE__=long \
  -U__INTMAX_MAX__ -D__INTMAX_MAX__=0x7fffffffffffffffL \
  -U__INTMAX_C `# -D'__INTMAX_C(c)=c ## L'` \
  -U__UINT_FAST16_MAX__ -D__UINT_FAST16_MAX__=0xffffffffffffffffUL \
  `#-U__UINT_FAST32_TYPE__ -D'__UINT_FAST32_TYPE__=long unsigned int'` \
  `#-U__UINT_FAST64_TYPE__ -D'__UINT_FAST64_TYPE__=long unsigned int'` \
  -U__UINT_FAST64_MAX__ -D__UINT_FAST64_MAX__=0xffffffffffffffffUL \
  -U__UINT_LEAST64_MAX__ -D__UINT_LEAST64_MAX__=0xffffffffffffffffUL \
  `#-U__UINT64_TYPE__ -D'__UINT64_TYPE__=long unsigned int'` \
  -U__UINT64_MAX__ -D__UINT64_MAX__=0xffffffffffffffffUL \
  -U__UINT64_C `# -D'__UINT64_C(c)=c ## UL'` \
  -U__UINTMAX_TYPE__ `# -D'__UINTMAX_TYPE__=long unsigned int'` \
  -U__UINTMAX_MAX__ -D__UINTMAX_MAX__=0xffffffffffffffffUL \
  -U__UINTMAX_C `# -D'__UINTMAX_C(c)=c ## UL'` \
  -U__INTPTR_TYPE__ -D__INTPTR_TYPE__=long \
  `#-U__UINTPTR_TYPE__ -D'__UINTPTR_TYPE__=long unsigned int'` \
  -U__UINTPTR_MAX__ -D__UINTPTR_MAX__=0xffffffffffffffffUL \
  `#-U__PTRDIFF_TYPE__ -D__PTRDIFF_TYPE__=long` \
  -U__PTRDIFF_MAX__ -D__PTRDIFF_MAX__=0x7fffffffffffffffL \
  -U__LONG_WIDTH__ -D__LONG_WIDTH__=64"

MY_CFLAGS="-nostdinc $MY_DEFINES -Wno-error"
MY_CXXFLAGS="-nostdinc++ -fpermissive $MY_CFLAGS"

# "echo | gcc -E -x - -v" and "echo | g++ -E -x c++ - -v" vs
# "echo | x86_64-w64-mingw32-gcc -E -x - -v" and "echo | x86_64-w64-mingw32-g++ -E -x c++ - -v"
MY_INCLUDE_DIRS=" \
  -I$HOME/newlib-cygwin/newlib/libc/machine/shared_x86 \
  -isystem /usr/lib/gcc/x86_64-pc-cygwin/11/include \
  -isystem /usr/include \
  -isystem /usr/include/w32api"
MY_CXX_INCLUDE_DIRS=" \
  -isystem /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++ \
  -isystem /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++/x86_64-pc-cygwin \
  -isystem /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++/backward"

export CPPFLAGS="$MY_CFLAGS $MY_INCLUDE_DIRS"
export CFLAGS="$MY_CFLAGS $MY_INCLUDE_DIRS"
export CXXFLAGS="$MY_CXXFLAGS $MY_CXX_INCLUDE_DIRS $MY_INCLUDE_DIRS"

export CPPFLAGS_FOR_BUILD="$CPPFLAGS"
export CFLAGS_FOR_BUILD="$CFLAGS"
export CXXFLAGS_FOR_BUILD="$CXXFLAGS"

export CPPFLAGS_FOR_HOST="$CPPFLAGS"
export CFLAGS_FOR_HOST="$CFLAGS"
export CXXFLAGS_FOR_HOST="$CXXFLAGS"

export CPPFLAGS_FOR_TARGET="$CPPFLAGS"
export CFLAGS_FOR_TARGET="$CFLAGS"
export CXXFLAGS_FOR_TARGET="$CXXFLAGS"

$HOME/newlib-cygwin/configure \
  --build=$BUILD \
  --host=$TARGET \
  --target=$TARGET \
  --prefix=$HOME/newlib-cygwin/install/ \
  --enable-debugging \
  --disable-werror \
  --disable-doc \
  CPPFLAGS="$CPPFLAGS" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"\

make V=1 -j$(nproc)
make V=1 install
