starship::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) starship
else
	curl -fsSL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz | \
		sudo tar xfz - -C /usr/local/bin starship
endif
