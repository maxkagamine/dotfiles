pngcrush::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) pngcrush
else ifdef APT
	sudo apt-get install -qy pngcrush
else
	$(error pngcrush install requires apt or pacman)
endif
