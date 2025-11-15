json-tools:: python
	$(PRINT)
ifdef PACMAN
	$(PACMAN) jq fx yq
else
	sudo curl -fsSL https://github.com/stedolan/jq/releases/latest/download/jq-linux64 \
		-o /usr/local/bin/jq
	sudo chmod +x /usr/local/bin/jq

	sudo curl -fsSL https://github.com/antonmedv/fx/releases/latest/download/fx_linux_amd64 \
		-o /usr/local/bin/fx
	sudo chmod +x /usr/local/bin/fx

# Note: there are two "yq"s that do similar things. The Arch package is this
# one, https://github.com/kislyuk/yq; the other is https://github.com/mikefarah/yq
	pipx upgrade --install yq
endif
