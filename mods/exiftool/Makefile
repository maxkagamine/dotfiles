exiftool::
	$(PRINT)
ifdef APT
	sudo apt-get install -qy libimage-exiftool-perl
else ifdef PACMAN
	$(PACMAN) perl-image-exiftool
else
	$(error exiftool install requires apt or pacman)
endif
