gpg::
	$(PRINT)
ifdef APT
	sudo apt-get install -qy scdaemon pcscd
else ifdef PACMAN
	$(PACMAN) openssh
else
	$(error gpg install requires apt)
endif
