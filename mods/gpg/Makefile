gpg::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) openssh
endif
ifdef WSL_DISTRO_NAME
	sudo ln -s "$$(pwd)/vendor/pinentry/pinentry.exe" /usr/local/bin/pinentry
else
	sudo ln -s /bin/pinentry /usr/local/bin/pinentry
endif
