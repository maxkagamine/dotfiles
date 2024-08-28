ifdef PACMAN
gif-tools::
	$(PRINT)
	$(PACMAN) gifsicle gifski
else
gif-tools:: cargo
	$(PRINT)
ifdef APT
	sudo apt-get install -qy gifsicle
else
	$(warning Skipping gifsicle, no apt-get)
endif
	cargo install gifski
endif
