ifneq "${WSL_DISTRO_NAME}" ""
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

docker:: ${DOCKER_CREDENTIAL_HELPER}
	$(PRINT)
ifeq "$(shell echo $${HOSTNAME,,})" "sovngarde"
	$(info skipping docker install on sovngarde)
else ifndef APT
	$(error docker install requires apt)
else
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
	sudo usermod -aG docker $$USER
	docker completion bash | sudo tee /etc/bash_completion.d/docker > /dev/null
endif
	tee ~/.docker/config.json >/dev/null <<<"$$DOCKER_CONFIG"

docker-credential-wincred:
	$(PRINT)
	curl -fsSL https://github.com/docker/docker-credential-helpers/releases/download/v0.8.2/docker-credential-wincred-v0.8.2.windows-amd64.exe \
		-o ~/.local/bin/docker-credential-wincred
	chmod +x ~/.local/bin/docker-credential-wincred
