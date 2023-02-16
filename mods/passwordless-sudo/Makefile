define PASSWORDLESS_SUDOERS
Defaults  !env_reset
Defaults  !secure_path
%sudo     ALL=(ALL) NOPASSWD:ALL
endef
export PASSWORDLESS_SUDOERS

passwordless-sudo::
	$(PRINT)
	sudo EDITOR=tee visudo -f /etc/sudoers.d/passwordless >/dev/null <<<"$$PASSWORDLESS_SUDOERS"
