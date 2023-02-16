UPDATE_FFMPEG_IF_OLDER_THAN_DAYS=90
FFMPEG:=$(shell find "$$(type -P ffmpeg)" -mtime -$(UPDATE_FFMPEG_IF_OLDER_THAN_DAYS) 2>/dev/null)

ifdef FFMPEG
ffmpeg::
	$(info ffmpeg already installed and newer than $(UPDATE_FFMPEG_IF_OLDER_THAN_DAYS) days. `sudo rm $(FFMPEG)` to force update.)
else
ffmpeg:: ffmpeg-deps svt-av1 vmaf
	$(PRINT)
# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
	sudo rm -rf /tmp/ffmpeg
	cd /tmp && git clone -q --depth 1 https://git.ffmpeg.org/ffmpeg.git
	cd /tmp/ffmpeg && ./configure \
		--pkg-config-flags="--static" \
		--extra-libs="-lpthread -lm" \
		--ld="g++" \
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
	cd /tmp/ffmpeg && make -j $$(nproc)
	cd /tmp/ffmpeg && sudo make install
	sudo rm -rf /tmp/ffmpeg
endif

ffmpeg-deps:
	$(PRINT)
ifndef APT
	$(error ffmpeg install requires apt)
endif
	sudo apt-get update -qq
	sudo apt-get -qy install \
		autoconf \
		automake \
		build-essential \
		cmake \
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

svt-av1: ffmpeg-deps
	$(PRINT)
# https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Build-Guide.md#svt-av1-ffmpeg-plugin-installation
	sudo rm -rf /tmp/SVT-AV1
	cd /tmp && git clone -q --depth 1 https://gitlab.com/AOMediaCodec/SVT-AV1.git
	cd /tmp/SVT-AV1/Build && cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF
	cd /tmp/SVT-AV1/Build && make -j $$(nproc)
	cd /tmp/SVT-AV1/Build && sudo make install
	sudo rm -rf /tmp/SVT-AV1

vmaf: ffmpeg-deps
	$(PRINT)
# https://github.com/Netflix/vmaf/blob/master/libvmaf/README.md
	sudo rm -rf /tmp/vmaf
	cd /tmp && git clone -q --depth 1 https://github.com/Netflix/vmaf.git
	cd /tmp/vmaf/libvmaf && meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static build
	cd /tmp/vmaf/libvmaf/build && ninja
	cd /tmp/vmaf/libvmaf/build && sudo ninja install
	rm -rf /tmp/vmaf
