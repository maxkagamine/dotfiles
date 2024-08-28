man::
	$(PRINT)
ifndef PACMAN
	$(error man install requires pacman)
endif
	$(PACMAN) man-db man-pages
	sudo mandb -q
