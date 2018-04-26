#!/bin/bash
. init.sh

#
# Terminal setup
#

group 'Terminal setup'

# Set home directory to /home

task-start 'Setting home directory to /home'
if [[ -e /etc/passwd ]]; then
	task-end skip
else
	mkpasswd -c | awk '$6="/home"' FS=: OFS=: > /etc/passwd
	recycle ~
	export HOME=/home
	task-end
fi

# Set up symlinks

task-start 'Setting up home directory symlinks'
symlink-all ../home /home
task-end

# Add Git for Windows repo

task-start 'Adding Git for Windows package repo'
if grep -qF '[git-for-windows]' /etc/pacman.conf; then
	task-end skip
else

	# Latest update seems to break gawk (can't load inplace); nano broken as well
	# Leaving a temporary workaround in as I'll likely switch to WSL soon anyway
	# https://github.com/Alexpux/MSYS2-packages/issues/1127
	# https://github.com/Alexpux/MSYS2-packages/issues/1172

	# awk -i inplace '$0 == "[mingw32]" {
	awk '$0 == "[mingw32]" {
		print "[git-for-windows]"
		print "SigLevel = Never"
		print "Server = https://dl.bintray.com/git-for-windows/pacman/$arch\n"
	} { print }' /etc/pacman.conf > /etc/pacman.conf.new
	mv /etc/pacman.conf.new /etc/pacman.conf
	task-end
fi

# Install packages

task-start 'Installing packages'; echo
if ! pacman -Qi mingw-w64-x86_64-git &>/dev/null; then
	# Install Git for Windows
	# https://github.com/git-for-windows/git/wiki/Install-inside-MSYS2-proper
	echo -e '\e[43;30m   ^   BUCKLE UP                                             '
	echo             '  /!\  Replacing msys2-runtime. This will break everything!  '
	echo -e  '  \e(0qqq\e(B  Close and rerun setup once done.                      \e[m'
	sleep 5
	pacman -Sy --noconfirm git-for-windows/msys2-runtime git-for-windows/mingw-w64-x86_64-git \
		git-for-windows/mingw-w64-x86_64-git-doc-html git-for-windows/mingw-w64-x86_64-git-doc-man \
		git-for-windows/mingw-w64-x86_64-git-credential-manager
	echo -e '\nRestart setup.'
	exit
fi
superman install
echo; task-end

# Remove default launchers, maintenance tool, and GfW garbage

task-start 'Cleaning up root directory'
rm -f /autorebase.bat /components.xml /InstallationLog.txt /maintenancetool* /mingw*.* /msys2*.* /network.xml /git-*.exe
task-end

# Symlink conemu config

task-start 'Setting up ConEmu configuration'
ln -sft "$APPDATA" "$(realpath ../conemu.xml)"
cp ../terminal.ico /
task-end

# Merge registry file

task-start 'Associating .sh files & adding to context menu'
regedit //s ../terminal.reg
task-end

# Set msys env vars
# Doing this globally to ensure all shells behave the same

task-start 'Setting MSYS environment variables'
setx CHERE_INVOKING 1 > /dev/null
setx MSYSTEM MINGW64 > /dev/null
setx MSYS winsymlinks:nativestrict > /dev/null
setx MSYS2_PATH_TYPE inherit > /dev/null
task-end

# Add user bin and conemu to path

task-start 'Updating PATH'
[[ $(add-to-path ~/bin /c/Program\ Files/ConEmu /c/Program\ Files/ConEmu/ConEmu) ]] || task-end skip
task-end

# Remove default shortcuts

task-start 'Removing default shortcuts'
[[ $(find "$(cygpath -P)" -name 'MSYS*' -print -delete) ]] || task-end skip
task-end

# Set up cmd profile

task-start 'Setting up cmd profile'
reg add 'HKEY_CURRENT_USER\Software\Microsoft\Command Processor' \
	//v AutoRun //d "\"$(cygpath -aw ../cmdrc.bat)\"" //f > /dev/null
task-end

#
# Misc setup
#

group 'Misc setup'

# VS Code

task-start 'Symlinking VS Code configuration'
symlink-all ../vscode "$APPDATA/Code/User"
task-end

# User profile .gitconfig file

task-start 'Creating .gitconfig file in user profile for IDEs'
cat > "$USERPROFILE/.gitconfig" <<EOF
[core]
	excludesfile = "$(cygpath -am /home/.gitignore)"
EOF
attrib +h "$USERPROFILE/.gitconfig"
task-end
