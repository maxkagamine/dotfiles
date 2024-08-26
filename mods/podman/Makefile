# Note: cgroups v1 should be disabled. For wsl, set in %USERPROFILE%\.wslconfig:
#   [wsl2]
#   kernelCommandLine = cgroup_no_v1=all

podman::
	$(PRINT)
ifndef PACMAN
	$(error podman install requires pacman)
endif
	$(PACMAN) podman podman-compose podman-docker
# Squelch "Emulate Docker CLI using podman" message
	sudo touch /etc/containers/nodocker
