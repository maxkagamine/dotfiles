tree::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) tree
else ifdef APT
	sudo apt-get install -qy tree
else
	$(error tree install requires apt or pacman)
endif
