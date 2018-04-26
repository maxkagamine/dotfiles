@echo off

:: Usage: __new-package-json PATH
:: PATH may include a filename which will be ignored
:: Intended for use from a ShellNew command

cd /d %~dp1
for %%a in (.) do set dirname=%%~na

if not exist package.json (
    echo {>package.json
    echo   "name": "%dirname%",>> package.json
    echo   "version": "1.0.0",>> package.json
    echo   "private": true>> package.json
    echo }>> package.json
)
