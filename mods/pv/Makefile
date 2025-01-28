pv::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) pv
else ifdef APT
	sudo apt-get install -qy pv
else
	$(error pv install requires apt or pacman)
endif
