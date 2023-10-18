define AUTO_UPDATE_SCRIPT
#!/bin/bash
if ! apt-get update && apt-get upgrade -y && apt-get autoclean; then
	notify-send 'auto-update failed'
fi
endef
export AUTO_UPDATE_SCRIPT

# TODO: Move docker prune to cron.daily (& place in docker mod instead)
define WSL_CRONTAB
0 0 *   * * docker image prune -f && docker builder prune -f
0 0 */3 * * /home/max/.local/bin/cron-wrapper /mnt/s/Videos/YouTube\ Playlists/download-youtube-playlists.sh
* * *   * * /home/max/.local/bin/cron-wrapper /home/max/.local/bin/pull-from-seedbox
endef
export WSL_CRONTAB

# TODO: Create separate mods for Tamriel and Oblivion?
WSL_TARGETS:=wsl-auto-update wsl-bin wslu
ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
WSL_TARGETS:=$(WSL_TARGETS) wsl-mount-network-drive wsl-crontab
endif

wsl:: $(WSL_TARGETS)
	$(PRINT)
# Needed for wsl-gpg-agent.sh
	sudo apt-get install -qy socat

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
		"$$(pwd)/vendor/wsl2-ssh-pageant/wsl2-ssh-pageant.exe"
# WSL can run Windows exe's without the .exe extension, no wrapper needed!
	ln -sf \
		"$$(pwd)/vendor/wsl-notify-send/wsl-notify-send.exe" \
		~/.local/bin/notify-send

# cron-wrapper is located in misc-utils mod
# rclone used by pull-from-seedbox
wsl-crontab: misc-utils rclone
	$(PRINT)
	crontab - <<<"$$WSL_CRONTAB"

# https://wslutiliti.es/wslu/
# Was installed by default in WSL prior to 22.04 LTS
wslu:
	$(PRINT)
	sudo apt-get install -qy software-properties-common
	sudo add-apt-repository -yu ppa:wslutilities/wslu
	sudo apt-get install -qy wslu
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/wslview 999
	sudo update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/wslview 999
	sudo update-alternatives --install /usr/bin/open open /usr/bin/wslview 999

