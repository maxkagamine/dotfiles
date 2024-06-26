SHELL:=/bin/bash -o pipefail
MAKEFLAGS+=--always-make # This makes all targets "phony"
.DEFAULT_GOAL:=$(shell echo $${HOSTNAME,,})
APT:=$(shell command -v apt 2>/dev/null)
PRINT=$(info $(shell printf '\e[32m%-*s\e[m\n' $$(tput cols) $@ | perl -pe 's/(?<= ) /─/g'))

# Mod lists. Running `make` will install the mod list corresponding to the
# machine's hostname, thanks to the "default goal" above.
tamriel: \
  7zip \
  bash \
  bat \
  clef \
  docker \
  exiftool \
  ffmpeg \
  fx \
  fzf \
  gif-tools \
  git \
  gpg \
  hyperfine \
  imagemagick \
  img2pdf \
  json-tools \
  misc-utils \
  mkvtoolnix \
  nano \
  node \
  passwordless-sudo \
  python3 \
  shellcheck \
  sqlite3 \
  starship \
  sweetroll \
  tree \
  wsl \
  yt-dlp \

oblivion: tamriel # Same, but wsl mod will configure differently

sovngarde: \
  bash \
  bat \
  docker \
  fzf \
  git \
  htop \
  misc-utils \
  mkvtoolnix \
  nano \
  starship \
  sweetroll \
  unraid \

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
else
# https://gist.github.com/maxkagamine/7e3741b883a272230eb451bdd84a8e23
# MAKEFLAGS need to be reset to prevent weird behavior in stow's Makefile
	wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -O - | tar -xzC /tmp
	cd /tmp/stow* && ./configure && MFLAGS= MAKEFLAGS= make install
	rm -rf /tmp/stow*
endif

# Shellcheck (see .vscode/tasks.json)
test:
	@find mods -type f -exec awk '/^#.*sh/{printf "%s\0",FILENAME}{nextfile}' {} + | \
	 xargs -r0 shellcheck -xf gcc

watch:
ifeq "$(shell command -v inotifywait 2>/dev/null)" ""
	$(info Installing inotifywait...)
	@sudo apt-get install -y inotify-tools >/dev/null
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
	sudo apt-get install -y graphviz
endif
	make -Bnd tamriel sovngarde | \
		grep -Pv '(stow|Makefile)' | \
		make2graph | \
		sed 's/, color="red"//g' | \
		dot -Gmargin=0.3 -Gbgcolor=transparent -Tpng -o /dev/stdout | \
		magick /dev/stdin -channel RGB -negate -background '#0d1117' -alpha remove \
			.github/images/graph.png
