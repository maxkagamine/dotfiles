LOCALAPPDATA=$(shell wslpath "$$(cmd.exe /c echo %localappdata% 2>/dev/null)")
WSL_KEEPALIVE_EXE=$(LOCALAPPDATA)/Programs/wsl-keepalive.exe

define WSL_KEEPALIVE_SYSTEMD
[Unit]
Description=WSL Keepalive

[Service]
ExecStart=$(WSL_KEEPALIVE_EXE)

[Install]
WantedBy=multi-user.target
endef
export WSL_KEEPALIVE_SYSTEMD

# Smallest Windows program that does nothing forever. This is my own solution
# for keeping Windows from shutting down the WSL instance, since it can't do so
# while it's running an exe. An `instanceIdleTimeout` option was introduced in
# 2.5.4 that might eliminate the need for this, but it's still undocumented and
# unclear if it works on Win10.
define WSL_KEEPALIVE_ASM
subq    $$40, %rsp
.loop:
movl    $$-1, %ecx
call    Sleep
jmp     .loop
endef
export WSL_KEEPALIVE_ASM

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
	ln -sfT "$(LOCALAPPDATA)/Microsoft/Windows/Fonts" ~/.local/share/fonts
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

wsl-keepalive: cargo # cargo mod installs mingw32 for cross-compilation
	$(PRINT)
ifneq "$(wildcard /etc/systemd/system/wsl-keepalive.service)" ""
	sudo systemctl stop wsl-keepalive.service
endif
	x86_64-w64-mingw32-gcc -x assembler - -o $(WSL_KEEPALIVE_EXE) -s -nostdlib -lkernel32 <<<"$$WSL_KEEPALIVE_ASM"
	sudo tee /etc/systemd/system/wsl-keepalive.service >/dev/null <<<"$$WSL_KEEPALIVE_SYSTEMD"
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
