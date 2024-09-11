# TODO: Check the other utils' requirements

misc-utils::
	$(PRINT)

# weigh
ifndef PACMAN
ifeq "$(shell command -v bc 2>/dev/null)" ""
	$(warning bc not installed and pacman not available, weigh command will be work)
endif
else
	$(PACMAN) bc
endif
