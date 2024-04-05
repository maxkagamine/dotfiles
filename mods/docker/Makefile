docker::
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
