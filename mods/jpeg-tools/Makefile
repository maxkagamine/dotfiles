# libjxl provides cjpegli. Both of these are indirect deps of ffmpeg &
# mediainfo, but I want to make them explicit and add a helper function.
jpeg-tools::
	$(PRINT)
ifndef PACMAN
	$(error jpeg-tools install requires pacman)
endif
	$(PACMAN) libjxl libjpeg-turbo
