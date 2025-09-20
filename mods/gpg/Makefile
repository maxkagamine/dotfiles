gpg::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) openssh
endif
ifdef WSL_DISTRO_NAME
	sudo ln -sf "$$(pwd)/vendor/pinentry/pinentry.exe" /usr/local/bin/pinentry
else
	sudo ln -sf /bin/pinentry /usr/local/bin/pinentry
endif
