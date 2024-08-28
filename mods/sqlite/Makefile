sqlite::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) sqlite
else ifdef APT
	sudo apt-get install -qy sqlite3
else
	$(error sqlite install requires apt or pacman)
endif
