fzf: FZF_VERSION:=$(shell \
	curl -sI https://github.com/junegunn/fzf/releases/latest | \
	perl -ne '/^location:.*?([^\/]+)$$/i && print $$1')

fzf:: fd
	$(PRINT)
	$(info Downloading fzf v$(FZF_VERSION))
	curl -fsSL https://github.com/junegunn/fzf/releases/download/$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz | \
		sudo tar xfz - -C /usr/local/bin fzf
	sudo mkdir -p /usr/share/doc/fzf/examples
	sudo curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/$(FZF_VERSION)/shell/key-bindings.bash \
		-o /usr/share/doc/fzf/examples/key-bindings.bash

# Used by Ctrl+T & Alt+C shortcuts, see .config/bashrc.d/fzf.sh
fd: cargo
	$(PRINT)
	cargo install fd-find
