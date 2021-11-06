# maxkagamine's dotfiles&ensp;<a href="https://twitter.com/maxkagamine"><img src="https://abs.twimg.com/responsive-web/client-web/icon-default.ee534d85.png" height="24" /></a>

_"Mod it 'till it breaks"_

Behold, [GNU Stow](https://www.gnu.org/software/stow/manual/html_node/index.html#Top): the mod manager for your Linux home directory! Stow simply takes a folder of "packages" and automates symlinking the ones you want into a combined target directory. Anyone who's used Vortex or MO2 to mod games like [Skyrim](https://www.youtube.com/playlist?list=PLYooEAFUfhDfO3m_WQWkHdIB3Zh2kIXKp) will find this familiar: we keep our mod files organized into separate folders, and the mod manager combines them into the game's folder either by symlinks or virtualization. As Stow acts similarly, I figured I'd apply the "mod" concept to dotfiles.

Like a mod manager, we have the ability to create multiple "profiles" for different machines. Having written [absurdly complicated setup scripts](https://github.com/maxkagamine/dotfiles/blob/old/setup.ps1) in the past, I decided to keep things simpler this time around... each profile is just [a short bash script](./profiles/tamriel) not unlike a Dockerfile, and [./install](./install) is a mere one-liner.

## <img src="https://github.com/microsoft/terminal/raw/a74c37bbcd699ce2cd90bb5d81412663a6236fcc/res/terminal/images/StoreLogo.scale-100.png" height="30" align="top" /> [bash](./mods/bash)

Applies the convention of loading configuration files from a directory to bashrc: after setting some common aliases and such, sources every file in **~/.config/bashrc.d/**. This way the other mods can put their stuff in e.g. bashrc.d/git.sh rather than one big file as is traditional. (The system-wide /etc/profile already does this with /etc/profile.d/*.)

## <img src="https://raw.githubusercontent.com/vscode-icons/vscode-icons/3df43eb5a6dc932719159aa98d33d082cd1cceb0/icons/file_type_git.svg" align="top" height="30" /> [git](./mods/git)

[Git aliases](./mods/git/.config/bashrc.d/git.bashrc) + my gg function that I use so much [I wrote a blog post about it](https://kagamine.dev/en/gg-faster-git-commits/), and of course what would be a _Max Kagamine_ system without a myriad of [Skyrim references](https://kagamine.dev/en/fus-ro-dah/) (brace yourself).

## <img src="https://github.com/devicons/devicon/raw/2ae2a900d2f041da66e950e4d48052658d850630/icons/windows8/windows8-original.svg" align="top" height="30" /> [wsl](./mods/wsl)

This applies to [Tamriel, my main machine](https://photos.app.goo.gl/GYYD6cBjdmbnX3tf6) running the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/), because I can't computer without a command line but Windows is life (at least until Bethesda releases _Skyrim: Chrome OS Edition_).

> ### Setting up GPG & YubiKey for WSL
>  
> 1. Install [Gpg4win](https://gpg4win.org/download.html) & [YubiKey Manager](https://www.yubico.com/support/download/yubikey-manager/)
>    - Ignore the PINs in the PIV app; the OpenPGP app on the YubiKey [is separate](https://github.com/drduh/YubiKey-Guide/issues/248). I'd even disable PIV in "Interfaces" to avoid confusion if you're not using it.
> 2. Follow [Yubico's guide here](https://developers.yubico.com/PGP/SSH_authentication/Windows.html), but hold off on cloning something since we'll do that in WSL. You don't need PuTTY (the GPG agent replaces Pageant).
>    - Use Task Scheduler to run `"C:\Program Files (x86)\GnuPG\bin\gpg-connect-agent.exe" /bye` at log on. Remember to uncheck everything in Conditions. I enabled "If the task fails, restart every 1 minute" in Settings.
> 3. Use [wsl2-ssh-pageant](https://github.com/BlackReloaded/wsl2-ssh-pageant) to connect the Linux-side SSH and GPG agents to GPG running Windows-side.
> 4. After restarting WSL (`wsl.exe --shutdown`), you should be able to run `gpg --card-status` in Linux👍 Import your public key and test that it works with `ssh git@github.com`.

> ### powershell.exe: Permission denied,<br />explorer.exe: Permission denied, ...
>
> If you [enable Linux file permissions for /mnt](https://docs.microsoft.com/en-us/windows/wsl/file-permissions) and set directories and files to be respectively 755 and 644 by default as I do [here](./profiles/tamriel), programs in C:\Windows or Program Files won't be executable in Linux. For most programs, you can `chmod +x` from an elevated terminal, but to chmod PowerShell and other system programs, you'll need to first find the exe, right click, Properties &gt; Security &gt; Advanced, take ownership and give Administrators full control.
