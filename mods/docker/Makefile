ifdef WSL_DISTRO_NAME
DOCKER_CREDENTIAL_HELPER:=docker-credential-wincred
define DOCKER_CONFIG
{
	"auths": {
		"ghcr.io": {}
	},
	"psFormat": "table {{.Names}}\\t{{.Image}}\\t{{.Status}}",
	"credsStore": "wincred"
}
endef
else
# Could install cred helpers for different platforms w/o changing config.json
# simply by giving them all the same name (docker-credential-whatever)
DOCKER_CREDENTIAL_HELPER:=
define DOCKER_CONFIG
{
	"psFormat": "table {{.Names}}\\t{{.Image}}\\t{{.Status}}"
}
endef
endif
export DOCKER_CONFIG

# Installing the nvidia runtime allows for using CUDA in Docker in WSL
define TAMRIEL_DOCKER_DAEMON_CONFIG
{
	"runtimes": {
		"nvidia": {
			"path": "/usr/bin/nvidia-container-runtime",
			"runtimeArgs": []
		}
	},
	"features": {
		"containerd-snapshotter": true
	}
}
endef
export TAMRIEL_DOCKER_DAEMON_CONFIG

# Laptop's VPN has an MTU of 1280 (reduced from the default 1420 due to issues
# with public wifi causing ssh to hang at "expecting SSH2_MSG_KEX_ECDH_REPLY"),
# but the docker0 interface defaults to 1500 which results in TLS handshakes
# hanging when connecting to certain sites via HTTPS (such as GitHub). Figuring
# this out was a massive wild goose chase.
define OBLIVION_DOCKER_DAEMON_CONFIG
{
	"ip": "127.0.0.1",
	"mtu": 1280,
	"features": {
		"containerd-snapshotter": true
	}
}
endef
export OBLIVION_DOCKER_DAEMON_CONFIG

IGNORE_NVIDIA=IgnorePkg = nvidia-container-toolkit libnvidia-container

docker:: ${DOCKER_CREDENTIAL_HELPER} unbuffer
	$(PRINT)

ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
# Need to install the latest version that supports the installed CUDA (NVIDIA
# Control Panel > Help > System Information > Components)
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/release-notes.html
	sudo pacman -U --noconfirm \
		https://archive.archlinux.org/packages/l/libnvidia-container/libnvidia-container-1.17.0-1-x86_64.pkg.tar.zst \
		https://archive.archlinux.org/packages/n/nvidia-container-toolkit/nvidia-container-toolkit-1.17.0-1-x86_64.pkg.tar.zst
	grep -qF '$(IGNORE_NVIDIA)' /etc/pacman.conf || \
		sudo awk -i inplace '/^IgnorePkg/ { print; print "$(IGNORE_NVIDIA)"; next } 1' /etc/pacman.conf

	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json >/dev/null <<<"$$TAMRIEL_DOCKER_DAEMON_CONFIG"
endif

ifeq "$(shell echo $${HOSTNAME,,})" "oblivion"
	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json >/dev/null <<<"$$OBLIVION_DOCKER_DAEMON_CONFIG"
endif

ifeq "$(shell echo $${HOSTNAME,,})" "sovngarde"
	$(info skipping docker install on sovngarde)
else ifdef APT
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $$(lsb_release -cs 2>/dev/null) stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update -qq
	sudo apt-get install -qy \
		docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin
	sudo groupadd -f docker
	sudo usermod -aG docker $(USER)
	docker completion bash | sudo tee /etc/bash_completion.d/docker > /dev/null
else ifdef PACMAN
	$(PACMAN) docker docker-buildx docker-compose pigz dive
	sudo usermod -aG docker $(USER)
	sudo systemctl enable --now docker.service
else
	$(error docker install requires apt or pacman)
endif

	mkdir -p ~/.docker
	tee ~/.docker/config.json >/dev/null <<<"$$DOCKER_CONFIG"

docker-credential-wincred:
	$(PRINT)
	sudo curl -fsSL https://github.com/docker/docker-credential-helpers/releases/download/v0.8.2/docker-credential-wincred-v0.8.2.windows-amd64.exe \
		-o /usr/local/bin/docker-credential-wincred
	sudo chmod +x /usr/local/bin/docker-credential-wincred

unbuffer: # Used in docker.sh
	$(PRINT)
ifdef PACMAN
	$(PACMAN) expect
else ifdef APT
	sudo apt-get install -qy expect
else
	$(warning skipping unbuffer, no apt or pacman)
endif
