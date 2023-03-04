define AUTO_UPDATE_SCRIPT
#!/bin/bash
if ! apt-get update && apt-get upgrade -y && apt-get autoclean; then
	notify-send 'auto-update failed'
fi
endef
export AUTO_UPDATE_SCRIPT

define WSL_CRONTAB
0 0 *   * * docker image prune -f && docker builder prune -f
0 0 */3 * * SCRIPT_NAME='Download YouTube playlists' /home/max/.local/bin/cron-wrapper /mnt/s/Videos/YouTube\ Playlists/download.sh
* * *   * * /home/max/.local/bin/cron-wrapper /home/max/.local/bin/pull-from-seedbox
endef
export WSL_CRONTAB

wsl:: wsl-auto-update wsl-mount-network-drive wsl-bin wsl-crontab

wsl-auto-update:
	$(PRINT)
	sudo tee /etc/cron.weekly/auto-update >/dev/null <<<"$$AUTO_UPDATE_SCRIPT"
	sudo chmod +x /etc/cron.weekly/auto-update
	touch ~/.hushlogin

wsl-mount-network-drive:
	$(PRINT)
ifeq "$(shell grep /mnt/s /etc/fstab)" ""
	sudo tee -a /etc/fstab >/dev/null <<<'S: /mnt/s drvfs defaults 0 0'
	sudo mkdir /mnt/s
	sudo mount -a
else
	$(info Skipping, network drive S: already in fstab)
endif

wsl-bin:
	$(PRINT)
	mkdir -p ~/.local/bin
	ln -sft ~/.local/bin \
		"$$(pwd)/vendor/cmdmp3/cmdmp3.exe" \
		"$$(pwd)/vendor/nircmd/nircmdc.exe" \
		"$$(pwd)/vendor/wsl-notify-send/wsl-notify-send.exe" \
		"$$(pwd)/vendor/wsl2-ssh-pageant/wsl2-ssh-pageant.exe"

wsl-crontab: misc-utils # cron-wrapper is located in misc-utils mod
	$(PRINT)
	crontab - <<<"$$WSL_CRONTAB"
