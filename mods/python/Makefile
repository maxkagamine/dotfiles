python::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) python python-pip
else ifdef APT
	sudo apt-get install -qy python-is-python3 python3-pip python3-venv
else
	$(error python install requires pacman or apt)
endif
	sudo -H pip install --break-system-packages --root-user-action=ignore pipdeptree
