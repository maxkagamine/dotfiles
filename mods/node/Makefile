ifdef PACMAN

node::
	$(PRINT)
	$(PACMAN) nodejs npm

else

NODE_VERSION:=$(shell wget -qO- https://nodejs.org/dist/index.tab | sed '2q;d' | cut -f1)

node::
	$(PRINT)
ifeq "$(shell node --version 2>/dev/null)" "$(NODE_VERSION)"
	$(info Latest node version already installed)
else
	$(info Installing node $(NODE_VERSION))
	rm -rf ~/.local/lib/node_modules/{corepack,npm}
	wget -qO- https://nodejs.org/dist/$(NODE_VERSION)/node-$(NODE_VERSION)-linux-x64.tar.xz | \
		tar xfJ - -C ~/.local --strip-components=1 node-$(NODE_VERSION)-linux-x64/{bin,lib}
endif

endif


