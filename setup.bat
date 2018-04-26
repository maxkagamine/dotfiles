@echo off

set bash=C:\msys\usr\bin\bash.exe
set elevate=%~dp0\home\bin\elevate.exe

if not exist "%bash%" (
  echo MSYS installation not found.
  echo Expected bash at: %bash%
  pause
) else if not exist "%elevate%" (
  echo elevate.exe missing.
  echo Expected: %elevate%
  pause
) else (
  cd %~dp0\setup
  "%elevate%" "%bash%" main.sh
)
