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

wsl:: wsl-bin wsl-keepalive wsl-mount-network-drive wsl-timesyncd xsel-win
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

xsel-win:
	$(PRINT)
	sudo curl -fsSL https://github.com/maxkagamine/xsel-win/releases/latest/download/xsel -o /usr/local/bin/xsel
	sudo chmod 755 /usr/local/bin/xsel
