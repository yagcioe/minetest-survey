#!/bin/bash -eux

source common.sh

unpack_source libarchive

pushd "$BUILD_DIR/libarchive"

export CPPFLAGS="-I${INSTALL_DIR}/include"
export LDFLAGS="-L${INSTALL_DIR}/lib"
emconfigure ./configure \
  --enable-static \
  --disable-shared \
  --disable-bsdtar \
  --disable-bsdcat \
  --disable-bsdcpio \
  --enable-posix-regex-lib=libc \
  --disable-xattr --disable-acl --without-nettle --without-lzo2 \
  --without-cng  --without-lz4 \
  --without-xml2 --without-expat \
  --with-zstd \
  --prefix="$INSTALL_DIR"

emmake make
emmake make install

echo "libarchive OK"
