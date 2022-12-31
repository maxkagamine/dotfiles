#!/bin/bash
#
# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
set -eo pipefail
export PATH="$HOME/.local/bin:$PATH"
rm -rf /tmp/ffmpeg_{sources,build}
mkdir /tmp/ffmpeg_{sources,build}

echo '-------------------------------------------------------------------------'
echo '  Starting ffmpeg install'
echo '-------------------------------------------------------------------------'

sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libdav1d-dev \
  libfdk-aac-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libnuma-dev \
  libopus-dev \
  libsdl2-dev \
  libtool \
  libunistring-dev \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libvpx-dev \
  libx264-dev \
  libx265-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxcb1-dev \
  meson \
  nasm \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev

echo '-------------------------------------------------------------------------'
echo '  Building SVT-AV1'
echo '-------------------------------------------------------------------------'

cd /tmp/ffmpeg_sources
git clone --depth 1 https://gitlab.com/AOMediaCodec/SVT-AV1.git
mkdir -p SVT-AV1/build
cd SVT-AV1/build
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/tmp/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF ..
make -j"$(nproc)"
make install

echo '-------------------------------------------------------------------------'
echo '  Building VMAF'
echo '-------------------------------------------------------------------------'

cd /tmp/ffmpeg_sources
git clone --depth 1 https://github.com/Netflix/vmaf.git
mkdir -p vmaf/libvmaf/build
cd vmaf/libvmaf/build
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "/tmp/ffmpeg_build" --bindir="/tmp/ffmpeg_build/bin" --libdir="/tmp/ffmpeg_build/lib"
ninja
ninja install

echo '-------------------------------------------------------------------------'
echo '  Building ffmpeg'
echo '-------------------------------------------------------------------------'

cd /tmp/ffmpeg_sources
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PKG_CONFIG_PATH="/tmp/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="/tmp/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I/tmp/ffmpeg_build/include" \
  --extra-ldflags="-L/tmp/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$HOME/.local/bin" \
  --enable-gpl \
  --enable-gnutls \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libvmaf \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
make -j"$(nproc)"
make install

echo '-------------------------------------------------------------------------'
echo '  ffmpeg install complete'
echo '-------------------------------------------------------------------------'

rm -rf /tmp/ffmpeg_{sources,build}
