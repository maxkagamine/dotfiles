nano::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) nano shfmt
else ifdef APT
	sudo apt-get install -qy nano shfmt
else
	$(warning skipping nano install, no apt or pacman)
endif
	$(info Patching sh.nanorc to enable syntax highlighting of Ctrl+X,Ctrl+E (edit-and-execute-command))
	sudo sed -Ei 's/^(syntax sh .*\$$)"$$/\1\|\^\/tmp\/bash-"/' /usr/share/nano/sh.nanorc
