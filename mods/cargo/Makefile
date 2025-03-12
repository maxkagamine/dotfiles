export PATH:=$(HOME)/.cargo/bin:$(PATH)

cargo::
	$(PRINT)
	curl -fsSL https://sh.rustup.rs | sh -s -- -q -y --no-modify-path
ifdef PACMAN
	$(PACMAN) mingw-w64-gcc
	rustup target add x86_64-pc-windows-gnu
else
	$(warning no pacman, mingw-w64 will not be available for cross-compiling to Windows)
endif
