htop::
	$(PRINT)
ifeq "$(shell echo $${HOSTNAME,,})" "sovngarde"
	$(info skipping docker install on sovngarde)
else ifdef PACMAN
	$(PACMAN) htop
else
	$(error htop install requires pacman)
endif
