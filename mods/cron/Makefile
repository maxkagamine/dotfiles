CRONTAB_DEPS:=
export CRONTAB

ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
# rclone is used by pull-from-seedbox, which is in the wsl mod
CRONTAB_DEPS:=rclone trash
define CRONTAB
PATH=$(shell perl -pe 's/(?:^|(?<=:))[^:]+\/\.vscode-server\/[^:]+:|:[^:]+\/\.vscode-server\/[^:]+$$//g' <<<"$$PATH")

0    0 *   * * docker image prune -f && docker builder prune -f
0    0 */3 * * cron-wrapper /mnt/s/Videos/YouTube\ Playlists/download-youtube-playlists.sh
*    * *   * * DISABLE_ON_ERROR=1 cron-wrapper pull-from-seedbox
*/15 * *   * * WSL_DISTRO_NAME=Arch code --version # Update vscode-server in background
0    0 *   * * trash-empty 30
endef
endif

cron:: $(CRONTAB_DEPS) misc-utils # cron-wrapper uses title-case
	$(PRINT)
ifndef PACMAN
	$(error cron install requires pacman)
endif
# https://www.gnu.org/fun/jokes/ed-msg.en.html (used by cron-wrapper)
	$(PACMAN) cronie ed
	sudo systemctl enable --now cronie
ifdef CRONTAB
	+@printf 'Installing crontab:\n\n%s\n\n' \
		"$$(fold -w $$(($$(tput cols) - 8)) <<<"$$CRONTAB" | sed 's/^/    /')"
	crontab - <<<"$$CRONTAB"
else
	$(info No crontab for current system)
endif
