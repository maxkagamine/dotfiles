ncdu::
	$(PRINT)
ifeq "$(shell echo $${HOSTNAME,,})" "sovngarde"
	$(info skipping ncdu install on sovngarde)
else ifdef PACMAN
	$(PACMAN) ncdu
else ifdef APT
	sudo apt-get install -qy ncdu
else
	$(error ncdu install requires pacman or apt)
endif
