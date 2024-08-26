define TAMRIEL_CRONTAB
0 0 *   * * docker image prune -f && docker builder prune -f
0 0 */3 * * /home/max/.local/bin/cron-wrapper /mnt/s/Videos/YouTube\ Playlists/download-youtube-playlists.sh
* * *   * * DISABLE_ON_ERROR=1 /home/max/.local/bin/cron-wrapper /home/max/.local/bin/pull-from-seedbox
endef
export TAMRIEL_CRONTAB

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

# systemd normally sets the root directory's mount propagation to "shared" by
# default, but this doesn't happen in WSL because it thinks it's a container:
# https://github.com/systemd/systemd/blob/v256.5/src/shared/mount-setup.c#L440
# Not totally clear why podman needs this as it seems to work without, but this
# will squelch the warning if nothing else. Can confirm effect with `findmnt -o
# TARGET,PROPAGATION /` (note that systemd takes a few seconds to start).
define WSL_MOUNT_PROPAGATION
[Unit]
Description=WSL mount propagation

[Service]
ExecStart=mount --make-rshared /

[Install]
WantedBy=multi-user.target
endef
export WSL_MOUNT_PROPAGATION

WSL_TARGETS:= \
	wsl-bin wsl-keepalive wsl-mount-network-drive wsl-mount-propagation \
	wsl-timesyncd xsel-win

ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
WSL_TARGETS:=$(WSL_TARGETS) tamriel-crontab
endif

wsl:: $(WSL_TARGETS)
	$(PRINT)
ifdef APT # Make sure Ubuntu's open & browser commands point to our custom one
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser ~/.local/bin/open 999
	sudo update-alternatives --install /usr/bin/www-browser www-browser ~/.local/bin/open 999
	sudo update-alternatives --install /usr/bin/open open ~/.local/bin/open 999
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

wsl-keepalive:
	$(PRINT)
	sudo tee /etc/systemd/system/wsl-keepalive.service >/dev/null <<<"$$WSL_KEEPALIVE"
	sudo systemctl enable wsl-keepalive.service
	sudo systemctl start wsl-keepalive.service

wsl-mount-network-drive:
	$(PRINT)
ifeq "$(shell grep /mnt/s /etc/fstab)" ""
	sudo tee -a /etc/fstab >/dev/null <<<'S: /mnt/s drvfs defaults 0 0'
	sudo mkdir /mnt/s
	sudo mount -a
else
	$(info Skipping, network drive S: already in fstab)
endif

wsl-mount-propagation:
	$(PRINT)
	sudo tee /etc/systemd/system/wsl-mount-propagation.service >/dev/null <<<"$$WSL_MOUNT_PROPAGATION"
	sudo systemctl enable wsl-mount-propagation.service
	sudo systemctl start wsl-mount-propagation.service

# Fixes a bug where the time in WSL gets out of sync with Windows
wsl-timesyncd:
	$(PRINT)
ifdef APT
	sudo apt-get install -qy systemd-timesyncd
else ifeq "$(wildcard /etc/systemd/timesyncd.conf)" ""
# Should be installed by default on Arch
	$(error systemd-timesyncd not installed and no apt to install it)
endif
	sudo mkdir -p /etc/systemd/system/systemd-timesyncd.service.d
	sudo tee /etc/systemd/system/systemd-timesyncd.service.d/override.conf >/dev/null <<<"$$WSL_TIMESYNCD_OVERRIDE"
	sudo systemctl daemon-reload
	sudo systemctl start systemd-timesyncd

# cron-wrapper is located in misc-utils mod; rclone is used by pull-from-seedbox
tamriel-crontab: misc-utils rclone
	$(PRINT)
	crontab - <<<"$$TAMRIEL_CRONTAB"

xsel-win:
	$(PRINT)
	sudo curl -fsSL https://github.com/maxkagamine/xsel-win/releases/latest/download/xsel -o /usr/local/bin/xsel
	sudo chmod 755 /usr/local/bin/xsel
