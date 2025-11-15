python::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) python python-pip python-pipx
else ifdef APT
	sudo apt-get install -qy python-is-python3 python3-pip python3-venv pipx
else
	$(error python install requires pacman or apt)
endif
	pipx upgrade --install pipdeptree
