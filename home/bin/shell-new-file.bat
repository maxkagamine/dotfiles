@echo off
setlocal EnableDelayedExpansion

:: Usage: shell-new-file.bat PATH NAME [ARGS]
::
:: Intended for use from a ShellNew command. See associated registry file.
::
:: PATH    %1 in the command, where Windows wants the new file created (the
::         default filename will be ignored).
:: NAME    The name for the new file, created empty unless listed below.
:: ARGS    Options for the new file depending on the name (see below).
::
:: Special file names:
::
:: package.json
::   Creates a new private package.json using the dirname as the package name.
:: .gitignore
::   May pass the name of a file in https://github.com/github/gitignore (sans
::   extension) to use it as a template; otherwise empty.
::
:: If an empty file is created, or if the file already exists, opens it in
:: VS Code for editing.

if [%1] == [] (
  echo Intended for use from a ShellNew command.
  pause & exit /b
)

set name=%2
set file=%~dp1\%name%
for %%a in ("%~dp1\.") do set dirname=%%~na

if not exist "%file%" (

  :: package.json
  if [%name%] == [package.json] (
    echo {>"%file%"
    echo   "name": "%dirname%",>>"%file%"
    echo   "version": "1.0.0",>>"%file%"
    echo   "private": true>>"%file%"
    echo }>>"%file%"
    exit /b
  )

  :: .gitignore
  if [%name%] == [.gitignore] if not [%3] == [] (
    set url=https://raw.githubusercontent.com/github/gitignore/master/%3.gitignore
    echo Downloading !url!
    powershell -NoProfile -Command "Invoke-WebRequest '!url!' -OutFile '%file%'"
    if not !errorlevel! == 0 pause
    exit /b
  )

)

start "" "C:\Program Files\Microsoft VS Code\Code.exe" "%file%"
