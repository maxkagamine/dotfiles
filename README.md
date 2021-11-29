# maxkagamine's dotfiles&ensp;<a href="https://twitter.com/intent/tweet?url=https%3A%2F%2Fgithub.com%2Fmaxkagamine%2Fdotfiles&via=maxkagamine&text=Awesome%20dotfiles%21&hashtags=programming"><img src="https://abs.twimg.com/responsive-web/client-web/icon-default.ee534d85.png" height="24" /></a>

<p align="center"><img src="doc/cross-machine awesomeness.png" /></p>

Behold, [GNU Stow](https://www.gnu.org/software/stow/manual/html_node/index.html#Top): the mod manager for your Linux home directory! Anyone who's used Vortex or MO2 to mod games like [Skyrim](https://www.youtube.com/playlist?list=PLYooEAFUfhDfO3m_WQWkHdIB3Zh2kIXKp) will find how this works surprisingly familiar: mod (dot) files are organized into separate folders, and the mod manager (stow) combines them into the game (home) directory using symlinks.

Continuing with the mod manager theme, different machines can have a different "profile" or mod list. Having written [excessively-complicated setup scripts](https://github.com/maxkagamine/dotfiles/blob/old/setup.ps1) in the past, I decided to keep things simple this time around &mdash; no [complex framework](https://alexpearce.me/2021/07/managing-dotfiles-with-nix/), no [YAML files](https://github.com/anishathalye/dotbot) &mdash; each profile is just [a short bash script](./profiles/tamriel), sortof like a Dockerfile.

## <img src="https://github.com/microsoft/terminal/raw/a74c37bbcd699ce2cd90bb5d81412663a6236fcc/res/terminal/images/StoreLogo.scale-100.png" height="30" align="top" /> [bash](./mods/bash)

Applies the convention of loading configuration files from a directory to bashrc: after setting some common aliases and such, sources every file in **~/.config/bashrc.d/**. This way the other mods can put their stuff in e.g. bashrc.d/git.sh rather than one big file as is traditional. (The system-wide /etc/profile already does this with /etc/profile.d/*.)

## <img src="https://raw.githubusercontent.com/vscode-icons/vscode-icons/3df43eb5a6dc932719159aa98d33d082cd1cceb0/icons/file_type_git.svg" align="top" height="30" /> [git](./mods/git)

[Git aliases](./mods/git/.config/bashrc.d/git.bashrc) + my gg function that I use so much [I wrote a blog post about it](https://kagamine.dev/en/gg-faster-git-commits/), and of course what would be a _Max Kagamine_ system without a myriad of [Skyrim references](https://kagamine.dev/en/fus-ro-dah/) (brace yourself).

## &#8201;<img src="https://github.com/devicons/devicon/raw/2ae2a900d2f041da66e950e4d48052658d850630/icons/windows8/windows8-original.svg" height="22" />&#8202; [wsl](./mods/wsl)

This applies to [Tamriel, my main machine](https://photos.app.goo.gl/GYYD6cBjdmbnX3tf6) running the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/), because I can't computer without a command line but Windows is life (at least until Bethesda releases _Skyrim: Chrome OS Edition_).

> ### Setting up GPG & YubiKey for WSL
>  
> 1. Install [Gpg4win](https://gpg4win.org/download.html) & [YubiKey Manager](https://www.yubico.com/support/download/yubikey-manager/)
>    - Ignore the PINs in the PIV app; the OpenPGP app on the YubiKey [is separate](https://github.com/drduh/YubiKey-Guide/issues/248). I'd even disable PIV in "Interfaces" to avoid confusion if you're not using it.
> 2. Follow [Yubico's guide here](https://developers.yubico.com/PGP/SSH_authentication/Windows.html), but hold off on cloning something since we'll do that in WSL. You don't need PuTTY (the GPG agent replaces Pageant).
>    - Use Task Scheduler to run `"C:\Program Files (x86)\GnuPG\bin\gpg-connect-agent.exe" /bye` at log on. Remember to uncheck everything in Conditions. I enabled "If the task fails, restart every 1 minute" in Settings.
> 3. Use [wsl2-ssh-pageant](https://github.com/BlackReloaded/wsl2-ssh-pageant) to connect the Linux-side SSH and GPG agents to GPG running Windows-side.
> 4. After restarting WSL (`wsl.exe --shutdown`), you should be able to run `gpg --card-status` in Linux👍 Import your public key and test that it works with `ssh git@github.com`.

## &#8202;<img src="http://craftassets.unraid.net.s3.amazonaws.com/static/favicon/android-chrome-192x192.png?v=1.0" align="top" height="25" /> [unraid](./mods/unraid)

For [Sovngarde, my NAS.](https://photos.app.goo.gl/GYYD6cBjdmbnX3tf6) There isn't much here (literally just a `CDPATH`), but if you're running Unraid as well, see [**How to install GNU Stow on Unraid**](https://gist.github.com/maxkagamine/7e3741b883a272230eb451bdd84a8e23). Here's my user script, set to run on array start, if it happens to be useful:

<details>
<summary><code>cat /boot/config/plugins/user.scripts/scripts/install_dotfiles/script</code></summary>

```sh
#!/bin/bash
#name=Install dotfiles
#description=&lpar;Re&rpar;clone & install dotfiles.
#argumentDescription=Branch
#argumentDefault=master
#clearLog=true
set -eo pipefail

export PATH="/usr/local/bin:$PATH"
export HOME=/root

DOTFILES_DIR=~/dotfiles
BRANCH=${1:-master}

# Nuke existing dotfiles
[[ -d "$DOTFILES_DIR" ]] && make -C "$DOTFILES_DIR" clean
rm -rfv ~/.bashrc ~/.bash_profile "$DOTFILES_DIR"

# Clone repo
git clone -b "$BRANCH" https://github.com/maxkagamine/dotfiles.git "$DOTFILES_DIR"

# Install
cd "$DOTFILES_DIR"
make
```

</details>

---

### _Best part about this setup is you can easily create tailored "mod lists" and get a consistent terminal experience across machines. (The [starship](https://starship.rs/) prompt is especially nice for this &mdash; did you notice the ssh in the screenshot at the top?)_

---

## [dircolors](./mods/dircolors)

(Psst: if you want to change your ls colors, [my file](./mods/dircolors/.config/dircolors) might be an easier starting-off point than `--print-database`. I spent the time formatting it so you don't have to.)

## [empty string is git status](./mods/empty_string_is_git_status/.config/bashrc.d/zz_empty_string_is_git_status.sh)

> <i><ruby>Mukashi mukashi <rp>(</rp><rt>Once upon a time</rt><rp>)</rp>...</i>  
> “`git status` is too long,” Max thought as he sat at his desk.  
> So with the magic of `git config --global`, it became `git s`.  
> ...But that was too long.  
> So he aliased it to `gs` in his bashrc; just two letters, see?  
> But these two, too, were too long!  
> So he dropped the 's', just `g`, now, short as can be.  
> But even one letter 'twas one letter too long!  
> And so it became, the shortest `git status` of all:  
> **Empty string!**

True story. This is a trick I learned long ago: using `PROMPT_COMMAND` to compare the last history entry to that which was seen the previous time the prompt was shown, as hitting enter at an empty prompt will run the command again, but the last history number will be the same. Side effect is hitting <kbd>Ctrl+C</kbd> (instead of <kbd>Ctrl+U</kbd>) or <kbd>Alt+Shift+#</kbd> at a prompt will trigger git status, too.

## [fzf](./mods/fzf/.config/bashrc.d/fzf.sh)

Bash integration for fzf; enables [keyboard shortcuts for fuzzy completion](https://github.com/junegunn/fzf#key-bindings-for-command-line) with fancy, syntax-highlighted previews powered by [bat](https://github.com/sharkdp/bat) + a custom [🦇**batview**](mods/fzf/.local/bin/batview) script that shows archive listings & audio/video/image metadata (loosely inspired by [lesspipe](https://github.com/wofr06/lesspipe) and [batpipe](https://github.com/eth-p/bat-extras)).

See also [<img src="https://raw.githubusercontent.com/vscode-icons/vscode-icons/3df43eb5a6dc932719159aa98d33d082cd1cceb0/icons/file_type_git.svg" height="15" />**git-branch-fzf**](mods/git/.local/bin/git-branch-fzf), my awesome fzf-powered interactive branch switcher with keyboard shortcuts to toggle remote branches, delete branches (including remote and even the current branch!), and to [fetch the latest](mods/git/.local/bin/git-checkout-latest) of a branch before switching.

## [nano](./mods/nano/.config/nano/nanorc)

<img src="https://i.imgur.com/8sqd67K.png" height="375" />

## [node](./mods/node/.config/bashrc.d/node.sh)

~~Thirty-nine thousand node_modules files~~&nbsp; Just some npm aliases.

## [starship](./mods/starship/.config)

[Awesome universal prompt!](https://starship.rs/) 🚀
