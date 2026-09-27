jpeg-tools::
	$(PRINT)
ifndef PACMAN
	$(error jpeg-tools install requires pacman)
endif
# libjxl provides cjpegli; libjpeg-turbo provides jpegtran. Both are indirect
# deps of ffmpeg & mediainfo, but I want to make them explicit.
	$(PACMAN) libjxl libjpeg-turbo
