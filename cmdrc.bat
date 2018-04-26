@echo off

:: Prompt

set prompt=$p$_$g$s

:: Set window transparency (compiled ahk script in ~/bin)

where "set-cmd-transparency.exe" >nul 2>nul
if %errorlevel% == 0 "set-cmd-transparency.exe"
