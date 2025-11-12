yt-dlp::
	$(PRINT)
ifndef PACMAN
# We're installing yt-dlp from the GitHub releases so that it can always be kept
# up to date (without having to update the entire system), but we still need
# pacman to install some dependencies.
	$(error yt-dlp install requires pacman)
endif

	sudo curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
		-o /usr/local/bin/yt-dlp
	sudo chmod +x /usr/local/bin/yt-dlp

	sudo mkdir -p /etc/cron.hourly
	sudo tee /etc/cron.hourly/update-yt-dlp <<<$$'#!/bin/sh\n/usr/local/bin/yt-dlp -U\n' >/dev/null
	sudo chmod +x /etc/cron.hourly/update-yt-dlp

# Using deno as the JS runtime[0], as Node's permissions model (as of v25) is
# not designed to protect against malicious code. From the docs[1]:
#
# > The permission model implements a "seat belt" approach, which prevents
# > trusted code from unintentionally changing files or using resources that
# > access has not explicitly been granted to. It does not provide security
# > guarantees in the presence of malicious code. Malicious code can bypass the
# > permission model and execute arbitrary code without the restrictions imposed
# > by the permission model.
#
# And in particular:
#
# > The Permission Model, by default, restricts access to the file system
# > through the node:fs module. It does not guarantee that users will not be
# > able to access the file system through other means, such as through the
# > node:sqlite module.
#
# [0]: https://github.com/yt-dlp/yt-dlp/wiki/EJS
# [1]: https://nodejs.org/api/permissions.html
	$(PACMAN) deno

# pycryptodomex is for encrypted streams, mutagen for embedding thumbnails
	$(PACMAN) python-pycryptodomex python-mutagen
