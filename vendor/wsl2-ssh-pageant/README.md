## [wsl2-ssh-pageant](https://github.com/BlackReloaded/wsl2-ssh-pageant)

Copyright (c) 2020 Marc Kohlbau  
License: MIT

Recompiled without `-ldflags -H=windowsgui` to fix the
[bug](https://github.com/BlackReloaded/wsl2-ssh-pageant/issues/38#issuecomment-1082442579)
where wsl2-ssh-pageant.exe processes don't quit after running gpg commands and
pile up in Task Manager.
