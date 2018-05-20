$title = $host.UI.RawUI.WindowTitle = "Environment setup"
$global:currentTask = -1
$global:taskCount = (Select-String "Start-Task" -Path $PSCommandPath).Matches.Count - 2
function Start-Task($task) {
  Write-Progress -Activity $title -Status $task -PercentComplete (++$global:currentTask / $global:taskCount * 100)
}

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

  # Allow sudo without password

  Start-Task "Allowing sudo without password"

  wsl sudo bash -c "grep -q NOPASSWD /etc/sudoers || echo $'\n%sudo\tALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo > /dev/null"

  # Whoop

  Write-Progress -Activity $title -Status "Done" -PercentComplete 100
  Write-Host "Done."

} catch {
  Write-Error $_.Exception
}

Write-Host -NoNewLine "Press any key to close...";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
