$ErrorActionPreference = "Stop"

$title = $host.UI.RawUI.WindowTitle = "Environment setup"
$global:currentTask = -1
$global:taskCount = (Select-String "Start-Task" -Path $PSCommandPath).Matches.Count - 2

function Start-Task($task) {
  Write-Progress -Activity $title -Status $task -PercentComplete (++$global:currentTask / $global:taskCount * 100)
}

function Exec([scriptblock] $cmd) {
  & $cmd
  if ($LastExitCode -ne 0) {
    throw "Command exited with non-zero exit code."
  }
}

Write-Output "`n`n`n`n`n`n`n`n" # Move cursor down below progress bar

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

  exec { wsl sudo true }

  # Set environment variables

  Start-Task "Setting environment variables"
  [Environment]::SetEnvironmentVariable("WSLENV", "USERPROFILE/p", "User") # https://blogs.msdn.microsoft.com/commandline/2017/12/22/share-environment-vars-between-wsl-and-windows/

  # Allow sudo without password

  Start-Task "Allowing sudo without password"
  exec { wsl sudo bash -c "grep -q NOPASSWD /etc/sudoers || echo $'\n%sudo\tALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo > /dev/null" }

  # Set home directory

  Start-Task "Setting home directory"

  $user = $(wsl whoami)
  $homeWin = Join-Path $PSScriptRoot "home"
  $homeWsl = wsl wslpath $homeWin.Replace("\", "/")

  exec { wsl sudo awk -i inplace -v user=$user -v home=$homeWsl '{ \$1 ~ \"^\" user && \$6=home; print }' FS=: OFS=: /etc/passwd }

  # Add bin directories to PATH

  Start-Task "Adding bin directories to PATH"

  $binDirs = (Join-Path $homeWin ".local\bin"), (Join-Path $homeWin "bin")

  $userPath = [Environment]::GetEnvironmentVariable("PATH", "User").Split(";")
  $userPath = $binDirs + @($userPath | Where-Object { !($binDirs -contains $_) })
  [Environment]::SetEnvironmentVariable("PATH", $userPath -join ";", "User")

  # Install things

  Start-Task "Preparing to install packages"
  exec { wsl sudo add-apt-repository -y ppa:git-core/ppa }
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

  # Whoop

  Write-Progress -Activity $title -Status "Done" -PercentComplete 100
  Write-Host "Done"

} catch {
  Write-Error $_.Exception -ea Continue
  Write-Progress -Activity $title -Completed
}

Write-Host -NoNewLine "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
