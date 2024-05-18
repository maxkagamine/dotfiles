define MKVMERGE_DOCKERFILE
FROM ubuntu
RUN apt-get update && apt-get install -y mkvtoolnix
WORKDIR /srv
ENTRYPOINT /usr/bin/mkvmerge
endef
export MKVMERGE_DOCKERFILE

mkvtoolnix:: jq
	$(PRINT)
ifeq "$(shell echo $${HOSTNAME,,})" "sovngarde"
	docker build -t mkvmerge - <<<"$$MKVMERGE_DOCKERFILE"
	for x in mkvmerge mkvextract mkvinfo mkvpropedit; do \
		printf '#!/bin/sh\ndocker run -it --rm -v "$$(pwd):/srv" --entrypoint /usr/bin/%s mkvmerge "$$@"\n' "$$x" | \
			sudo tee "/usr/local/bin/$$x" && sudo chmod +x "/usr/local/bin/$$x"; \
	done
else ifndef APT
	$(error mkvtoolnix install requires apt)
else
	sudo apt-get install -qy mkvtoolnix
endif
