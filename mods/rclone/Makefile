rclone::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) rclone
else
# Exits with 3 if latest already installed
	curl -fsSL https://rclone.org/install.sh | sudo bash || [[ $$? == 3 ]]
	sudo rclone genautocomplete bash
endif
