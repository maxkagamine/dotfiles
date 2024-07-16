FZF_VERSION:=0.54.0

fzf:: fd
	$(PRINT)
	$(info Downloading fzf v$(FZF_VERSION))
	curl -fsSL https://github.com/junegunn/fzf/releases/download/v$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz | \
		sudo tar xfz - -C /usr/local/bin fzf
	sudo mkdir -p /usr/share/doc/fzf/examples
	sudo curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/v$(FZF_VERSION)/shell/key-bindings.bash \
		-o /usr/share/doc/fzf/examples/key-bindings.bash

# Used by Ctrl+T & Alt+C shortcuts, see .config/bashrc.d/fzf.sh
fd: cargo
	$(PRINT)
	cargo install fd-find
