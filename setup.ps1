$ErrorActionPreference = "Stop"

$title = $host.UI.RawUI.WindowTitle = "Environment setup"
$global:currentTask = -1
$global:taskCount = (Select-String "Start-Task" -Path $PSCommandPath).Matches.Count - 2

function Start-Task($task) {
  $percent = ++$global:currentTask / $global:taskCount * 100
  Write-Progress -Activity $title -Status $task -PercentComplete $percent
  $host.UI.RawUI.WindowTitle = "{0} ({1}%) / {2}" -f $title, [Math]::Round($percent), $task
}

function Exec([scriptblock] $cmd) {
  & $cmd
  if ($LastExitCode -ne 0) {
    throw "Command exited with non-zero exit code."
  }
}

function Convert-ToWslPath($path) {
  exec { wsl wslpath $path.Replace("\", "/") }
}

function Mount-DrvFs($driveLetter) {
  # Drives need to be mounted in fstab before bind mounts: https://github.com/Microsoft/WSL/issues/2636#issuecomment-378746406
  $device = $driveLetter.ToUpper() + ":"
  wsl grep -q "^$device " /etc/fstab
  if ($LastExitCode -ne 0) {
    Write-Output "Adding drive $device to fstab"
    $mount = "{0} /mnt/{1} drvfs rw,noatime,uid=1000,gid=1000,metadata,umask=22,fmask=11 0 0" -f $device, $driveLetter.ToLower()
    exec { $mount | wsl sudo tee -a /etc/fstab > $null }
  }
}

function Mount-Bind($sourceWin, $destWsl) {
  exec { wsl mkdir -p -- $destWsl }
  Mount-DrvFs $sourceWin.Substring(0, 1)
  $device = (Convert-ToWslPath $sourceWin).Replace(" ", "\040")
  wsl grep -q "^$($device.Replace("\", "\\\\")) " /etc/fstab
  if ($LastExitCode -ne 0) {
    $mountPoint = $destWsl.Replace(" ", "\040")
    Write-Output "Adding $mountPoint -> $device to fstab"
    exec { "{0} {1} none bind 0 0" -f $device, $mountPoint | wsl sudo tee -a /etc/fstab > $null }
  }
}

function New-Symlink($link, $target, [switch] $force) {
  # New-Item does not yet support developer mode unprivileged symlinks: https://github.com/PowerShell/PowerShell/issues/2845
  if (Test-Path $target -PathType Container) {
    if ($force) {
      # Bug in Remove-Item https://github.com/powershell/powershell/issues/621
      [System.IO.Directory]::Delete($link, $true)
    }
    exec { cmd /c mklink /d $link $target > $null }
  } else {
    if ($force) {
      Remove-Item $link -Force -ea SilentlyContinue
    }
    exec { cmd /c mklink $link $target > $null }
  }
}

Write-Output "`n`n`n`n`n`n`n`n" # Move cursor down below progress bar to start

try {

  # Check if wsl installed and developer mode enabled (required for symlinks)

  Start-Task "Checking system"

  if (!(Get-Command wsl -ea SilentlyContinue)) {
    throw "WSL not installed."
  }

  $key = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -ea SilentlyContinue
  if ($key.AllowDevelopmentWithoutDevLicense -ne 1) {
    throw "Developer mode not enabled."
  }

  # Set environment variables

  Start-Task "Setting environment variables"
  [Environment]::SetEnvironmentVariable("WSLENV", "USERPROFILE/p", "User") # https://blogs.msdn.microsoft.com/commandline/2017/12/22/share-environment-vars-between-wsl-and-windows/
  [Environment]::SetEnvironmentVariable("WSLGIT_USE_INTERACTIVE_SHELL", "0", "User") # https://github.com/andy-5/wslgit

  # Configure sudo

  Start-Task "Configuring sudo"

  $sudoers = @"
Defaults`t!env_reset
Defaults`t!secure_path
%sudo`tALL=(ALL) NOPASSWD:ALL
"@

  exec { $sudoers | wsl sudo bash -c "tr -d \$'\r' | EDITOR=tee visudo -f /etc/sudoers.d/verysecurewow > /dev/null" }

  # Set home directory
  # Using fstab rather than edit /etc/passwd to keep home directory from appearing as a git repo

  Start-Task "Setting home directory"

  $homeWin = Join-Path $PSScriptRoot "home"
  $homeWsl = $(wsl echo '$HOME')

  Mount-Bind $homeWin $homeWsl

  # Mount user folders under home directory
  # Using fstab here too as symlinks cannot cross drives: https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-17046

  Start-Task "Mounting user folders under home directory"

  $shellFolders = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

  $userFolders = @{
    "Documents" = [Environment]::GetFolderPath("MyDocuments")
    "Music" = [Environment]::GetFolderPath("MyMusic")
    "Pictures" = [Environment]::GetFolderPath("MyPictures")
    "Videos" = [Environment]::GetFolderPath("MyVideos")
    "Downloads" = $shellFolders."{374DE290-123F-4565-9164-39C4925E467B}"
    "Google Drive" = ($shellFolders.PSObject.Properties | Where-Object { $_.Value -like "*Google Drive*" } | Select-Object -First 1).Value
    "Projects" = ($shellFolders.PSObject.Properties | Where-Object { $_.Value -like "*Projects*" } | Select-Object -First 1).Value
    "Games" = "D:\Games" # Tamriel only
  }

  if ($userFolders."Google Drive" -eq $null) {
    $userFolders."Google Drive" = Join-Path $env:USERPROFILE "Google Drive"
  }

  foreach ($folder in $userFolders.GetEnumerator()) {
    if ($folder.Value -ne $null -and (Test-Path $folder.Value)) {
      Mount-Bind $folder.Value "$homeWsl/$($folder.Key)"
    }
  }

  # Add bin directories to PATH

  Start-Task "Adding bin directories to PATH"

  $binDirs = (Join-Path $homeWin ".local\bin"), (Join-Path $homeWin "bin")

  $userPath = [Environment]::GetEnvironmentVariable("PATH", "User").Split(";")
  $userPath = $binDirs + @($userPath | Where-Object { $binDirs -notcontains $_ })
  [Environment]::SetEnvironmentVariable("PATH", $userPath -join ";", "User")

  # Install things

  Start-Task "Preparing to install packages"
  exec { wsl sudo add-apt-repository -y ppa:git-core/ppa }
  exec { wsl sudo bash -c 'wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && sudo dpkg -i \$_ && rm \$_' }
  exec { bash -c "curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -" } # Runs apt-get update

  Start-Task "Installing apt packages"
  exec { wsl sudo ~/bin/superman apt install }

  Start-Task "Updating npm"
  exec { wsl sudo npm install -g npm }

  Start-Task "Installing pip"
  exec { bash -c "curl -sL https://bootstrap.pypa.io/get-pip.py | python3 - --user" }

  Start-Task "Installing npm packages"
  exec { wsl sudo ~/bin/superman npm install }

  Start-Task "Installing VS Code extensions"
  if (Get-Command code -ea SilentlyContinue) {
    exec { wsl ~/bin/superman code install }
  } else {
    Write-Output "VS Code not installed; skipping"
  }

  Start-Task "Installing youtube-dl"
  exec { wsl sudo bash -c 'curl -sL https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && chmod a+rx \$_' }

  Start-Task "Installing GPG pinentry for WSL"
  exec { wsl sudo bash -c 'curl -sL https://raw.githubusercontent.com/diablodale/pinentry-wsl-ps1/master/pinentry-wsl-ps1.sh -o /usr/local/bin/pinentry-wsl-ps1 && chmod a+rx \$_' }

  Start-Task "Installing shellcheck"
  exec { wsl sudo bash -c 'curl -sL https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz | tar xfJ - --strip-components 1 -C /usr/local/bin shellcheck-stable/shellcheck && chmod a+rx /usr/local/bin/shellcheck' }

  # Symlink conemu config

  Start-Task "Symlinking ConEmu config"
  New-Symlink $(Join-Path $env:APPDATA "conemu.xml") $(Join-Path $PSScriptRoot "conemu.xml") -Force
  New-Symlink $(Join-Path $env:APPDATA "terminal.ico") $(Join-Path $PSScriptRoot "terminal.ico") -Force

  # Associate .sh files & add to context menu

  Start-Task "Associating .sh files & adding to context menu"
  & "$homeWin\bin\elevate.exe" regedit.exe /s $(Join-Path $PSScriptRoot "terminal.reg")

  # Register cmd profile

  Start-Task "Registering cmd profile"
  New-Item "HKCU:\Software\Microsoft\Command Processor" -Force > $null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name "AutoRun" -Value $(Join-Path $PSScriptRoot "cmdrc.bat")

  # Set up vscode

  Start-Task "Setting up VS Code"
  New-Item $(Join-Path $env:APPDATA "Code\User") -ItemType Directory -Force > $null
  Get-ChildItem $(Join-Path $PSScriptRoot "vscode") | ForEach-Object {
    # Get target path
    $target = $(Join-Path $env:APPDATA "Code\User\$($_.Name)")
    # Send to recycle bin if existing regular file
    $existing = Get-Item $target -ea SilentlyContinue
    if ($existing -ne $null -and $existing.Attributes -notmatch "ReparsePoint") {
      & "$homeWin\bin\nircmdc.exe" moverecyclebin $target
    }
    # Symlink
    New-Symlink $target $_.FullName -Force
  }

  # Whoop

  Write-Progress -Activity $title -Status "Done" -PercentComplete 100
  Write-Host "Done"
  $host.UI.RawUI.WindowTitle = $title

} catch {
  Write-Error $_.Exception -ea Continue
  Write-Progress -Activity $title -Completed
}

Write-Host -NoNewLine "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
