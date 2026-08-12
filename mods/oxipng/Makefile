oxipng::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) oxipng
else ifdef APT
	sudo apt-get install -qy oxipng
else
	$(error oxipng install requires apt or pacman)
endif
