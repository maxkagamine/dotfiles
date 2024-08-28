hyperfine::
	$(PRINT)
ifdef APT
	sudo apt-get install -qy hyperfine
else ifdef PACMAN
	$(PACMAN) hyperfine
else
	$(error hyperfine install requires apt or pacman)
endif
