json-tools::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) jq fx
else
	sudo curl -fsSL https://github.com/stedolan/jq/releases/latest/download/jq-linux64 \
		-o /usr/local/bin/jq
	sudo chmod +x /usr/local/bin/jq

	sudo curl -fsSL https://github.com/antonmedv/fx/releases/latest/download/fx_linux_amd64 \
		-o /usr/local/bin/fx
	sudo chmod +x /usr/local/bin/fx
endif
