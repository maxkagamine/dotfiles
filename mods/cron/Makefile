CRONTAB_DEPS:=
export CRONTAB

ifeq "$(shell echo $${HOSTNAME,,})" "tamriel"
# cron-wrapper is located in misc-utils mod; rclone is used by pull-from-seedbox
CRONTAB_DEPS:=misc-utils rclone
define CRONTAB
0 0 *   * * docker image prune -f && docker builder prune -f
0 0 */3 * * /home/max/.local/bin/cron-wrapper /mnt/s/Videos/YouTube\ Playlists/download-youtube-playlists.sh
* * *   * * DISABLE_ON_ERROR=1 /home/max/.local/bin/cron-wrapper /home/max/.local/bin/pull-from-seedbox
endef
endif

cron:: $(CRONTAB_DEPS)
	$(PRINT)
ifndef PACMAN
	$(error cron install requires pacman)
endif
	$(PACMAN) cronie
ifdef CRONTAB
	+@printf 'Installing crontab:\n\n%s\n\n' \
		"$$(fold -w $$(($$(tput cols) - 8)) <<<"$$CRONTAB" | sed 's/^/    /')"
	crontab - <<<"$$CRONTAB"
else
	$(info No crontab for current system)
endif
