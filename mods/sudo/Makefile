define SUDOERS
Defaults  !env_reset
Defaults  !secure_path
max       ALL=(ALL) NOPASSWD:ALL
endef
export SUDOERS

sudo::
	$(PRINT)
	sudo EDITOR=tee visudo -f /etc/sudoers.d/max >/dev/null <<<"$$SUDOERS"
	sudo chmod 440 /etc/sudoers.d/max
