json-tools:: jq fx json_xs

# "jq is the standard json editor"
jq:
	$(PRINT)
	sudo curl -fsSL https://github.com/stedolan/jq/releases/latest/download/jq-linux64 \
		-o /usr/local/bin/jq
	sudo chmod +x /usr/local/bin/jq

# More intuitive json transforming using JS function chains, but slower than jq
fx:
	$(PRINT)
	sudo curl -fsSL https://github.com/antonmedv/fx/releases/latest/download/fx_linux_amd64 \
		-o /usr/local/bin/fx
	sudo chmod +x /usr/local/bin/fx

# Faster pretty-printer than jq, for git diffs using textconv
json_xs:
	$(PRINT)
ifdef APT
	sudo apt-get install -qy libjson-xs-perl
else
	$(warning Skipping json_xs, no apt-get)
endif
