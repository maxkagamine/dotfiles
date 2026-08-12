# gallery-dl:: json-tools # mangadex-covers script uses jq
# 	$(PRINT)
# 	sudo curl -fsSL https://codeberg.org/mikf/gallery-dl/releases/download/latest/gallery-dl.bin \
# 		-o /usr/local/bin/gallery-dl
# 	sudo chmod +x /usr/local/bin/gallery-dl

# 	sudo mkdir -p /etc/cron.hourly
# 	sudo tee /etc/cron.hourly/update-gallery-dl <<<$$'#!/bin/sh\n/usr/local/bin/gallery-dl -U\n' >/dev/null
# 	sudo chmod +x /etc/cron.hourly/update-gallery-dl


# https://github.com/mikf/gallery-dl/issues/9393
# https://github.com/mikf/gallery-dl/issues/7729
# https://codeberg.org/mikf/gallery-dl/issues/7
# https://codeberg.org/mikf/gallery-dl/pulls/28

GALLERY_DL_SITE_PACKAGES=$(shell ~/.local/share/pipx/venvs/gallery-dl/bin/python -c 'import sysconfig; print(sysconfig.get_path("purelib"))')

gallery-dl:: python json-tools # mangadex-covers script uses jq
	$(PRINT)
	pipx install -f git+https://codeberg.org/mikf/gallery-dl
	pipx inject -f gallery-dl curl_cffi
	curl -fsSL 'https://codeberg.org/mikf/gallery-dl/raw/commit/ed8402735b73be148f13244261c8d448c52ac267/gallery_dl/extractor/curl_cffi_shim.py' \
		-o '$(GALLERY_DL_SITE_PACKAGES)/gallery_dl/extractor/curl_cffi_shim.py'
	curl -fsSL 'https://codeberg.org/mikf/gallery-dl/raw/commit/ed8402735b73be148f13244261c8d448c52ac267/gallery_dl/extractor/fanbox.py' \
		-o '$(GALLERY_DL_SITE_PACKAGES)/gallery_dl/extractor/fanbox.py'
