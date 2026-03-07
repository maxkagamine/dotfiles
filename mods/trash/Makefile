ifdef PACMAN
trash::
	$(PRINT)
	$(PACMAN) trash-cli
else
trash:: python
	$(PRINT)
	pipx upgrade --install trash-cli
endif
