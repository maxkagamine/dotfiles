export PATH:=$(HOME)/.cargo/bin:$(PATH)

cargo::
	$(PRINT)
	curl -fsSL https://sh.rustup.rs | sh -s -- -q -y --no-modify-path
ifdef PACMAN
	$(PACMAN) mingw-w64-gcc
	rustup target add x86_64-pc-windows-gnu
	cargo install cargo-expand
else
	$(warning no pacman, not setting up rust dev environment)
endif
