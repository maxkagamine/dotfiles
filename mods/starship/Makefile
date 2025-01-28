starship::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) starship
else
	curl -fsSL https://github.com/starship/starship/releases/latest/download/starship-$(shell uname -m)-unknown-linux-musl.tar.gz | \
		sudo tar xfz - -C /usr/local/bin starship
endif
