htop::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) htop
else ifdef APT
	sudo apt-get install -qy htop
else
	$(error htop install requires apt or pacman)
endif
