define AUTO_UPDATE_SCRIPT
#!/bin/bash
if ! apt-get update && apt-get upgrade -y && apt-get autoclean; then
	notify-send 'auto-update failed'
fi
endef
export AUTO_UPDATE_SCRIPT

wsl::
	$(PRINT)

	sudo tee /etc/cron.weekly/auto-update >/dev/null <<<"$$AUTO_UPDATE_SCRIPT"
	sudo chmod +x /etc/cron.weekly/auto-update
	touch ~/.hushlogin

ifeq "$(shell grep /mnt/s /etc/fstab)" ""
	sudo tee -a /etc/fstab >/dev/null <<<'S: /mnt/s drvfs defaults 0 0'
	sudo mkdir /mnt/s
	sudo mount -a
endif

	mkdir -p ~/.local/bin
	ln -sft ~/.local/bin \
		"$$(pwd)/vendor/cmdmp3/cmdmp3.exe" \
		"$$(pwd)/vendor/nircmd/nircmdc.exe" \
		"$$(pwd)/vendor/wsl-notify-send/wsl-notify-send.exe" \
		"$$(pwd)/vendor/wsl2-ssh-pageant/wsl2-ssh-pageant.exe"

