SHELL:=/bin/bash -o pipefail
MAKEFLAGS+=--always-make # This makes all targets "phony"
.DEFAULT_GOAL:=$(shell echo $${HOSTNAME,,})
APT:=$(shell command -v apt 2>/dev/null)
PRINT=$(info $(shell printf '\e[32m%-*s\e[m\n' $$(tput cols) $@ | perl -pe 's/(?<= ) /─/g'))

ifneq "$(shell command -v pacman 2>/dev/null)" ""
PACMAN:=sudo pacman -S --noconfirm --needed
endif

BASHRC_FILES:=mods/bash/.bashrc $(wildcard mods/*/.config/bashrc.d/*)
SHELL_SCRIPTS:=$(shell find mods -type f -exec awk '/^#!.*sh/{print FILENAME}{nextfile}' {} +)

# Mod lists. Running `make` will install the mod list corresponding to the
# machine's hostname, thanks to the "default goal" above.
tamriel: \
	archive-tools \
	bash \
	bat \
	cron \
	dig \
	docker \
	exiftool \
	fclones \
	fd \
	ffmpeg \
	fzf \
	gallery-dl \
	gif-tools \
	git \
	gpg \
	htop \
	hyperfine \
	ifconfig \
	imagemagick \
	json-tools \
	man \
	misc-utils \
	mkvtoolnix \
	nano \
	ncdu \
	node \
	pv \
	python \
	rsync \
	shellcheck \
	sqlite \
	starship \
	sudo \
	sweetroll \
	tree \
	wget \
	whois \
	wsl \
	xdelta3 \
	yt-dlp \

oblivion: tamriel

sovngarde: \
	bash \
	bat \
	docker \
	fclones \
	fd \
	fzf \
	git \
	mkvtoolnix \
	nano \
	ncdu \
	starship \
	sweetroll \
	unraid \

server: \
	bash \
	docker \
	git \
	htop \
	nano \
	ncdu \
	pv \
	starship \
	tree \

# Create targets for each mod. Double colon targets are separate targets with
# the same name that run in series; this lets mods define additional install
# steps or depend upon other mods via their included Makefile.
$(notdir $(wildcard mods/*)):: stow
	$(PRINT)
	stow $@

include mods/*/Makefile

# Install stow
stow:
	$(PRINT)
ifdef APT
	sudo apt-get update -qq
	sudo apt-get install -qy stow
else ifdef PACMAN
# Perform a system upgrade before beginning to make sure there are no outdated
# package dependencies (Arch is designed to update everything in unison, so
# pacman -S pkg won't simply update pkg's dependencies)
# https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported
	$(PACMAN) -yu stow
else
# https://gist.github.com/maxkagamine/7e3741b883a272230eb451bdd84a8e23
# MAKEFLAGS need to be reset to prevent weird behavior in stow's Makefile
	wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -O - | tar -xzC /tmp
	cd /tmp/stow* && ./configure && MFLAGS= MAKEFLAGS= make install
	rm -rf /tmp/stow*
endif

# Shellcheck (see .vscode/tasks.json)
test:
	@{ echo '#!/bin/bash'; printf '. %s\n' $(BASHRC_FILES); } | \
	 shellcheck -axf gcc - $(SHELL_SCRIPTS) | \
	 grep -v '^/'

watch:
ifeq "$(shell command -v inotifywait 2>/dev/null)" ""
	$(info Installing inotifywait...)
ifdef APT
	@sudo apt-get install -y inotify-tools >/dev/null
else ifdef PACMAN
	@$(PACMAN) inotify-tools
else
	$(error inotifywait install requires apt or pacman)
endif
endif
	@while $(MAKE) test; inotifywait -qre close_write mods; do :; done

# Unnecessary visualization
# https://github.com/lindenb/makefile2graph
graph:
ifeq "$(shell command -v make2graph 2>/dev/null)" ""
	rm -rf /tmp/make2graph
	git clone https://github.com/lindenb/makefile2graph.git /tmp/make2graph
	make -C /tmp/make2graph
	sudo make -C /tmp/make2graph install
	rm -rf /tmp/make2graph
endif
ifeq "$(shell command -v dot 2>/dev/null)" ""
ifdef APT
	sudo apt-get install -y graphviz
else ifdef PACMAN
	$(PACMAN) graphviz
else
	$(error graphviz install requires apt or pacman)
endif
endif
	make -Bnd tamriel sovngarde | \
		grep -Pv '(stow|Makefile)' | \
		make2graph | \
		sed 's/, color="red"//g' | \
		dot -Gmargin=0.3 -Gbgcolor=transparent -Tpng -o /dev/stdout | \
		magick /dev/stdin -channel RGB -negate -background '#0d1117' -alpha remove \
			.github/images/graph.png
