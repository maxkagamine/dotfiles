podman::
	$(PRINT)
ifndef PACMAN
	$(error podman install requires pacman)
endif
	$(PACMAN) podman podman-compose podman-docker
# Allow non-root to bind to port 80+
	sudo tee /etc/sysctl.d/90-unprivileged-ports.conf >/dev/null \
		<<<'net.ipv4.ip_unprivileged_port_start = 0'
# Load those settings for the current session
	sudo sysctl -p /etc/sysctl.d/90-unprivileged-ports.conf
# Squelch "Emulate Docker CLI using podman" message
	sudo touch /etc/containers/nodocker

# Note: cgroups v1 should be disabled. For wsl, set in %USERPROFILE%\.wslconfig:
#   [wsl2]
#   kernelCommandLine = cgroup_no_v1=all
