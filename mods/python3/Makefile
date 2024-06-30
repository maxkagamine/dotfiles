python3::
	$(PRINT)
ifndef APT
	$(error python3 install requires apt)
endif
	sudo apt-get install -qy python-is-python3 python3-pip python3-venv
	sudo -H pip install --break-system-packages --root-user-action=ignore pipdeptree
