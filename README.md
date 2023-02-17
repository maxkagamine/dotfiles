# maxkagamine's dotfiles

<p align="center"><img src=".github/images/screenshot.png" /></p>

**[<img src=".github/images/icons/terminal.png" height="19" valign="middle" /> bash](#-bash)**
&nbsp;|&nbsp;
**[<img src=".github/images/icons/git.svg" height="16" valign="middle" /> git](#-git)**
&nbsp;|&nbsp;
**[<img src=".github/images/icons/windows.svg" height="14" valign="middle" /> wsl](#-wsl)**
&nbsp;|&nbsp;
**[<img src=".github/images/icons/unraid.png" height="14" valign="middle" /> unraid](#-unraid)**
&nbsp;|&nbsp;
**[<img src=".github/images/icons/mkvtoolnix.png" height="14" valign="middle" /> mkvtoolnix](#-mkvtoolnix)**
&nbsp;|
**[⚙&hairsp;misc utils](#misc-utils)**
&nbsp;|&nbsp;
**[<img src=".github/images/icons/sweetroll.png" height="14" valign="middle" /> sweetroll](#-sweetroll)**
&nbsp;|&nbsp;
[more&hellip;](#docker)

Behold, [GNU Stow][stow]: the mod manager for your Linux home directory! Anyone
who's used Vortex or MO2 to mod games like [Skyrim][skyrim] will find this
familiar: mod (dot) files are organized into separate folders, and the mod
manager (stow) combines them into the game (home) directory using symlinks.

As Stow doesn't ([yet][stow todo]) support pre/post-install hooks, I'm emulating
it by placing Makefiles in the mod directories and including them from [the main
Makefile](Makefile). This keeps mods self-contained with any needed package
install steps etc., and also allows mods to _depend on other mods_, with Make
automatically figuring out which mods need to be installed and in what
order:

![Dependency graph](.github/images/graph.png)

Best part about this setup is it doesn't require any frameworks, dotfile
managers, or YAML files. Just run `make`.

## <img src=".github/images/icons/terminal.png" height="30" align="top" /> [bash](mods/bash)

Applies the convention of loading configuration files from a directory to
bashrc: after setting some common aliases and such, sources every file in
**~/.config/bashrc.d/**. This way the other mods can put their stuff in e.g.
bashrc.d/git.sh rather than one big file as is traditional. (The system-wide
/etc/profile already does this with /etc/profile.d/*.)

> (Psst: if you want to change your ls colors, [my
> file](mods/bash/.config/dircolors) might be an easier starting-off point than
> `--print-database`. I spent the time formatting it so you don't have to.)

## <img src=".github/images/icons/git.svg" align="top" height="30" /> [git](mods/git)

[Git aliases](mods/git/.config/bashrc.d/git.sh) and
[aliases](mods/git/.config/git/config) (including my favorite: the alias alias,
`git alias`) + the "gg" function I use so much [I wrote an article about
it][gg-faster-git-commits], and of course what would be a _Max Kagamine_ system
without a myriad of [Skyrim references][fus-ro-dah] (brace yourself).

Oh and _[empty string is git
status](mods/git/.config/bashrc.d/zz_empty_string_is_git_status.sh):_

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

True story. This is a trick I learned a long time ago: using `PROMPT_COMMAND`
(or a [precmd hook][bash-preexec]) to compare the last history entry to that
which was seen the previous time the prompt was shown, as hitting enter at an
empty prompt will run the prompt command again, but the last history number will
be the same. Side effect is hitting <kbd>Ctrl+C</kbd> (but not <kbd>Ctrl+U</kbd>
or <kbd>Alt+Shift+#</kbd>) at a prompt will trigger git status, too.

Also, check out [<img src=".github/images/icons/git.svg" height="15"
/>**git-branch-fzf**](mods/git/.local/bin/git-branch-fzf), my awesome
[fzf]-powered interactive branch switcher with keyboard shortcuts to toggle
remote branches, delete branches (including remote and even the current
branch!), and to [fetch the latest](mods/git/.local/bin/git-checkout-latest) of
a branch **before** switching.

## <img src=".github/images/icons/windows.svg" height="22" />&hairsp; [wsl](mods/wsl)

For "Tamriel," my main machine running the [Windows Subsystem for
Linux][wsl], because I can't computer
without a command line but Windows is life (at least until Bethesda releases
_Skyrim: Chrome OS Edition_).

> ### Setting up GPG & YubiKey for WSL
>  
> 1. Install [Gpg4win](https://gpg4win.org/download.html) & [YubiKey Manager](https://www.yubico.com/support/download/yubikey-manager/)
>    - Ignore the PINs in the PIV app; the OpenPGP app on the YubiKey [is separate](https://github.com/drduh/YubiKey-Guide/issues/248). I'd even disable PIV in "Interfaces" to avoid confusion if you're not using it.
> 2. Follow [Yubico's guide here](https://developers.yubico.com/PGP/SSH_authentication/Windows.html), but hold off on cloning something since we'll do that in WSL (skip steps 1 and 8). **You don't need PuTTY** (the GPG agent replaces Pageant).
>    - Use Task Scheduler to run `"C:\Program Files (x86)\GnuPG\bin\gpg-connect-agent.exe" /bye` at log on. Remember to uncheck everything in Conditions. I enabled "If the task fails, restart every 1 minute" in Settings.
> 3. Use [wsl2-ssh-pageant](https://github.com/BlackReloaded/wsl2-ssh-pageant) to connect the Linux-side SSH and GPG agents to GPG running Windows-side.
> 4. After restarting WSL (`wsl.exe --shutdown`), you should be able to run `gpg --card-status` in Linux👍 Import your public key and test that it works with `ssh git@github.com`.

## <img src=".github/images/icons/unraid.png" align="top" height="25" />&hairsp; [unraid](mods/unraid)

For "Sovngarde," my NAS. There isn't much here (literally just a `CDPATH`), but
if you're running Unraid as well, see **[How to install GNU Stow on Unraid]**.
Here's my user script, set to run on array start, if it happens to be useful:

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
rm -rfv ~/.bashrc ~/.bash_profile "$DOTFILES_DIR"

# Clean up symlinks
find ~ -xtype l -exec rm -v -- {} +
find ~ -depth -type d -empty -exec rmdir -v -- {} \;

# Clone repo
git clone -b "$BRANCH" https://github.com/maxkagamine/dotfiles.git "$DOTFILES_DIR"

# Install
cd "$DOTFILES_DIR"
make
```

</details>

Also take a look at:

- [User script to create backups of the flash drive and appdata on a
  schedule][backup_flash_and_appdata.sh]
- [Guide to running nginx on Unraid with a wildcard cert, using the official
  nginx and certbot Docker images][Nginx & certbot on Unraid]

## <img src=".github/images/icons/mkvtoolnix.png" align="top" height="25" /> [mkvtoolnix](mods/mkvtoolnix)

Tools for batch remuxing MKVs using mkvtoolnix:
[**mkv-ls**](mods/mkvtoolnix/.local/bin/mkv-ls) shows tracks in a table similar
to the GUI but groups identical track listings for batch processing with
[**mkv-batch**](mods/mkvtoolnix/.local/bin/mkv-batch).
  
For example, if I wanted to keep only the Japanese audio and remove the Signs &
Songs tracks from everything except the "Another Epilogue" special (which
`mkv-ls` shows has different tracks):
  
<img src=".github/images/mkv-ls.png" width="500" />

_(The escaped filenames in gray are for copy/pasting into the `mkv-batch`
command, but for screenshot purposes I used the `!()` glob syntax instead.)_

Additional tools:

- [**mkv-cat**](mods/mkvtoolnix/.local/bin/mkv-cat) - Concatenates the input
  MKVs, adding chapters for each file.
- [**mkv-rm-cover**](mods/mkvtoolnix/.local/bin/mkv-rm-cover) - Removes all
  image/jpeg and image/png attachments from the given MKVs.

## ⚙&hairsp;[misc utils](mods/misc-utils/.local/bin)

Miscellaneous utilities:

- [**append-crc**](mods/misc-utils/.local/bin/append-crc) — Adds (or updates) a
  file's crc32 hash to its filename.
- [**intersect-csvs**](mods/misc-utils/.local/bin/intersect-csvs) - Creates CSVs
  containing only rows that exist in two or more of the given CSVs. For example,
  given A.csv, B.csv, and C.csv, creates A+B.csv, A+C.csv, B+C.csv, and
  A+B+C.csv. I used this to create [a
  map](https://www.google.com/maps/d/viewer?mid=1kaE2O2LTjoS5Bf2YUCQ6OFJlXuert8U)
  of arcades in Tokyo that have my favorite games. It can easily be edited to
  handle files without a header row.
- [**mkanimedir**](mods/misc-utils/.local/bin/mkanimedir) — Turns a MAL link and
  a bunch of episodes into a nice folder.
- [**mkmoviedir**](mods/misc-utils/.local/bin/mkmoviedir) - Like mkanimedir but
  for an IMDb link.
- [**waifu2x**](mods/misc-utils/.local/bin/waifu2x) - Convenient wrapper for
  [waifu2x-ncnn-vulkan](https://github.com/nihui/waifu2x-ncnn-vulkan)
- [**weigh**](mods/misc-utils/.local/bin/weigh) — Shows the total size of files,
  directories, or stdin (optionally gzipped).

## <img src=".github/images/icons/sweetroll.png" height="23" valign="middle" /> &hairsp;[sweetroll](mods/sweetroll/.local/bin/sweetroll)

_I need to ask you to stop. That... committing... is making people nervous._

In case you missed it: [**Nuke a git repo with unrelenting force: the FUS RO DAH
command**][fus-ro-dah]

## [docker](mods/docker/.config/bashrc.d/docker.sh)

[ctop](https://github.com/bcicen/ctop) and
[runlike](https://github.com/lavie/runlike) functions (themselves run via
docker), the latter with color (via [bat](https://github.com/sharkdp/bat)) and
an fzf picker.

## [fzf](mods/fzf/.config/bashrc.d/fzf.sh)

Fancy [keyboard shortcuts][fzf keybindings] (also powers the aforementioned
[<img src=".github/images/icons/git.svg" height="15"
/>**git-branch-fzf**](mods/git/.local/bin/git-branch-fzf))

## [nano](mods/nano/.config/nano/nanorc)

<img src=".github/images/nano.png" height="375" />

## [yt-dlp](mods/yt-dlp/.config)

Because nothing on the Internet is guaranteed to be there tomorrow.

[stow]: https://www.gnu.org/software/stow/manual/html_node/index.html#Top
[stow todo]: https://github.com/aspiers/stow/blob/4ef5eca4a9d107b24e712bb4c2c91f47e7e0fb85/TODO
[skyrim]: https://www.youtube.com/playlist?list=PLYooEAFUfhDfO3m_WQWkHdIB3Zh2kIXKp
[fzf]: https://github.com/junegunn/fzf
[gg-faster-git-commits]: https://kagamine.dev/en/gg-faster-git-commits/
[fus-ro-dah]: https://kagamine.dev/en/fus-ro-dah/
[bash-preexec]: https://github.com/rcaloras/bash-preexec
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/
[How to install GNU Stow on Unraid]: https://gist.github.com/maxkagamine/7e3741b883a272230eb451bdd84a8e23
[backup_flash_and_appdata.sh]: https://gist.github.com/maxkagamine/0fda138ff67e4ad9fcad692fe852a168
[Nginx & certbot on Unraid]: https://gist.github.com/maxkagamine/5b6c34db6045d6413db3b333d6d2bae2
[fzf keybindings]: https://github.com/junegunn/fzf#key-bindings-for-command-line
