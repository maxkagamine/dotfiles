yt-dlp::
	$(PRINT)
	sudo curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
		-o /usr/local/bin/yt-dlp
	sudo chmod +x /usr/local/bin/yt-dlp
ifdef PACMAN
	$(PACMAN) python-pycryptodomex python-mutagen
else
	$(warning pacman not available, yt-dlp won't be able to use pycryptodomex to handle encrypted streams or mutagen to embed thumbnails)
endif
