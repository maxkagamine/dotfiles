shellcheck::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) shellcheck
else ifdef APT
	sudo apt-get install -qy shellcheck
else
	$(error shellcheck install requires apt or pacman)
endif
