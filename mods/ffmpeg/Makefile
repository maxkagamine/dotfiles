ffmpeg::
	$(PRINT)
ifdef APT
	sudo apt-get install -qy ffmpeg
else ifdef PACMAN
	$(PACMAN) ffmpeg
else
	$(error ffmpeg install requires apt or pacman)
endif
