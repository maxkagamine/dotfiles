SHELL=/bin/bash
profile=${shell echo $${HOSTNAME,,}}

.PHONY: install clean test

install:
	./profiles/${profile}

clean:
	find ~ -xtype l -exec rm -vi -- {} \;
	basename -a mods/* | xargs -p stow -D
	find ~/.config ~/.local -depth -type d -empty -exec rm -rvi -- {} \;

test:
	-fd -HE .git -t f '^\.?\w+(\.sh)?$$' -0 | \
		xargs -0 awk '!/^#.*sh/{nextfile}{printf "%s\0", FILENAME}' | \
		xargs -0 shellcheck -xf gcc | \
		sed 's/ note:/ warning:/'
