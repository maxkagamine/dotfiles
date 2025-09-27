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

define WSL_JOURNALD_CONF
[Journal]
SystemMaxUse=100M
endef
export WSL_JOURNALD_CONF

wsl:: wsl-bin wsl-journald-conf wsl-keepalive wsl-mount-network-drive wsl-timesyncd
	$(PRINT)
ifdef APT # Make sure Ubuntu's open & browser commands point to the open command from https://github.com/maxkagamine/wsl-tools
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser '/mnt/c/Program Files/wsl-tools/open' 999
	sudo update-alternatives --install /usr/bin/www-browser www-browser '/mnt/c/Program Files/wsl-tools/open' 999
	sudo update-alternatives --install /usr/bin/open open '/mnt/c/Program Files/wsl-tools/open' 999
endif
	sudo ln -sfT /mnt/c/Windows/Fonts /usr/local/share/fonts
	$(PACMAN) dos2unix

wsl-bin:
	$(PRINT)
	mkdir -p ~/.local/bin
	ln -sft ~/.local/bin "$$(pwd)/vendor/cmdmp3/cmdmp3.exe"
# WSL can run Windows exe's without the .exe extension, no wrapper needed!
	ln -sf \
		"$$(pwd)/vendor/wsl-notify-send/wsl-notify-send.exe" \
		~/.local/bin/notify-send

wsl-journald-conf:
	$(PRINT)
	sudo mkdir -p /etc/systemd/journald.conf.d
	sudo tee /etc/systemd/journald.conf.d/wsl.conf >/dev/null <<<"$$WSL_JOURNALD_CONF"
	sudo systemctl restart systemd-journald

wsl-keepalive:
	$(PRINT)
	sudo tee /etc/systemd/system/wsl-keepalive.service >/dev/null <<<"$$WSL_KEEPALIVE"
	sudo systemctl enable --now wsl-keepalive.service

wsl-mount-network-drive:
	$(PRINT)
ifeq "$(shell grep /mnt/s /etc/fstab)" ""
	sudo tee -a /etc/fstab >/dev/null <<<'S: /mnt/s drvfs defaults 0 0'
	sudo mkdir /mnt/s
	sudo mount -a
else
	$(info Skipping, network drive S: already in fstab)
endif

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
