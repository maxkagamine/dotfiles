@echo off

:: Usage: __new-file PATH FILENAME
:: Opens a file called FILENAME for editing in the directory of PATH
:: PATH may include a filename which will be ignored
:: Intended for use from a ShellNew command

start "" "C:\Program Files\Microsoft VS Code\Code.exe" "%~dp1\%2"
