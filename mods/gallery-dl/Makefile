gallery-dl:: json-tools # mangadex-covers script uses jq
	$(PRINT)
	sudo curl -fsSL https://codeberg.org/mikf/gallery-dl/releases/download/latest/gallery-dl.bin \
		-o /usr/local/bin/gallery-dl
	sudo chmod +x /usr/local/bin/gallery-dl

	sudo mkdir -p /etc/cron.hourly
	sudo tee /etc/cron.hourly/update-gallery-dl <<<$$'#!/bin/sh\n/usr/local/bin/gallery-dl -U\n' >/dev/null
	sudo chmod +x /etc/cron.hourly/update-gallery-dl
