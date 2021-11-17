SHELL=/bin/bash
profile=${shell echo $${HOSTNAME,,}}

.PHONY: install clean test

install:
	./profiles/${profile}

clean:
	find ~ -xtype l -exec rm -v -- {} +
	basename -a mods/* | xargs stow -D
	find ~/.config ~/.local -depth -type d -empty -exec rmdir -v -- {} \;

test:
	-fd -HE .git -t f '^\.?\w+(\.sh)?$$' -0 | \
		xargs -0 awk '!/^#.*sh/{nextfile}{printf "%s\0", FILENAME}' | \
		xargs -0 shellcheck -xf gcc | \
		sed 's/ note:/ warning:/'
