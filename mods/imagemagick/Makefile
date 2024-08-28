imagemagick::
	$(PRINT)
ifdef PACMAN
	$(PACMAN) imagemagick
else
# ImageMagick 7 (https://softcreatr.github.io/imei/)
	curl -fsSL https://raw.githubusercontent.com/SoftCreatR/imei/main/imei.sh | sudo bash - | sed 's/\o033c//'
endif

