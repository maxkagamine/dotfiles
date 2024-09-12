MISC_UTILS_TARGETS:=
MISC_UTILS_PACKAGES:=

# append-crc
MISC_UTILS_PACKAGES+=perl-archive-zip

# mkanimereadme
MISC_UTILS_TARGETS+=python

# weigh
MISC_UTILS_PACKAGES+=bc

misc-utils:: $(MISC_UTILS_TARGETS)
	$(PRINT)
ifndef PACMAN
	$(error misc-utils install requires pacman)
endif
	$(PACMAN) $(MISC_UTILS_PACKAGES)
