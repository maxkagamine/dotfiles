python::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) python python-pip python-pipx
else ifdef APT
	sudo apt-get install -qy python-is-python3 python3-pip python3-venv pipx
else
	$(error python install requires pacman or apt)
endif

# If python was upgraded to a newer version, the symlinks in pipx's venvs will
# be broken. This checks for that and reinstalls all packages if so. (-L follows
# symlinks, so -type l will only match if it's broken.)
	if find -L ~/.local/share/pipx/venvs -maxdepth 3 -name python -type l | grep -q .; then \
	  pipx reinstall-all; \
	fi

	pipx upgrade --install pipdeptree
