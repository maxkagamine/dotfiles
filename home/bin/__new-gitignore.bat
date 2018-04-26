@echo off
setlocal EnableDelayedExpansion

:: Usage: __new-gitignore PATH [TEMPLATE]
:: PATH may include a filename (which will be replaced with .gitignore)
:: TEMPLATE is the name of a file in https://github.com/github/gitignore, sans extension
:: Intended for use from a ShellNew command

set file=%~dp1\.gitignore

if exist "%file%" (
	echo .gitignore already exists
	pause
	exit /b 1
)

if [%2] == [] (
	type nul > "%file%"
) else (
	set url=https://raw.githubusercontent.com/github/gitignore/master/%2.gitignore
	echo Downloading !url!
	powershell -Command "Invoke-WebRequest '!url!' -OutFile '%file%'"
	if not !errorlevel! == 0 (
		pause
		exit /b 1
	)
)
