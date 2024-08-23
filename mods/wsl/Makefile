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
* * *   * * DISABLE_ON_ERROR=1 /home/max/.local/bin/cron-wrapper /home/max/.local/bin/pull-from-seedbox
endef
export WSL_CRONTAB

define WSL_KEEPALIVE
[Unit]
Description=WSL Keepalive

[Service]
ExecStartPre=/mnt/c/Windows/system32/waitfor.exe /si WSLKEEPALIVE
ExecStart=/mnt/c/Windows/system32/waitfor.exe WSLKEEPALIVE

[Install]
WantedBy=multi-user.target
endef
export WSL_KEEPALIVE

define WSL_TIMESYNCD_OVERRIDE
[Unit]
ConditionVirtualization=
endef
export WSL_TIMESYNCD_OVERRIDE

# TODO: Create separate mods for Tamriel and Oblivion?
WSL_TARGETS:=wsl-auto-update wsl-bin wsl-keepalive wsl-timesyncd
ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
WSL_TARGETS:=$(WSL_TARGETS) wsl-mount-network-drive wsl-crontab
endif

wsl:: $(WSL_TARGETS)
	$(PRINT)
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser ~/.local/bin/open 999
	sudo update-alternatives --install /usr/bin/www-browser www-browser ~/.local/bin/open 999
	sudo update-alternatives --install /usr/bin/open open ~/.local/bin/open 999

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
		"$$(pwd)/vendor/nircmd/nircmdc.exe"
# WSL can run Windows exe's without the .exe extension, no wrapper needed!
	ln -sf \
		"$$(pwd)/vendor/wsl-notify-send/wsl-notify-send.exe" \
		~/.local/bin/notify-send

# cron-wrapper is located in misc-utils mod
# rclone used by pull-from-seedbox
wsl-crontab: misc-utils rclone
	$(PRINT)
	crontab - <<<"$$WSL_CRONTAB"

wsl-keepalive:
	$(PRINT)
	sudo tee /etc/systemd/system/wsl-keepalive.service >/dev/null <<<"$$WSL_KEEPALIVE"
	sudo systemctl enable wsl-keepalive.service
	sudo systemctl start wsl-keepalive.service

# Fixes a bug where the time in WSL gets out of sync with Windows
wsl-timesyncd:
	$(PRINT)
	sudo apt-get install -qy systemd-timesyncd
	sudo mkdir -p /etc/systemd/system/systemd-timesyncd.service.d
	sudo tee /etc/systemd/system/systemd-timesyncd.service.d/override.conf >/dev/null <<<"$$WSL_TIMESYNCD_OVERRIDE"
	sudo systemctl daemon-reload
	sudo systemctl start systemd-timesyncd
