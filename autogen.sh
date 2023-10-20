#!/bin/sh
set -e
cd $(dirname $0)
/usr/bin/aclocal --force
/usr/bin/autoconf -f
/bin/rm -rf autom4te.cache
