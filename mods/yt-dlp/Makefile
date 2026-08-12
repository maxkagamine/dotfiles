yt-dlp::
	$(PRINT)
ifndef PACMAN
	$(error yt-dlp mod needs pacman to install deno)
endif

# yt-dlp = Platform-independent zipimport binary - missing curl_cffi needed to
#          impersonate a browser (and doesn't recognize python-curl_cffi
#          installed separately)
# yt-dlp_linux = Linux (glibc 2.17+) standalone x86_64 binary (inc. curl_cffi)
	sudo curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
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
