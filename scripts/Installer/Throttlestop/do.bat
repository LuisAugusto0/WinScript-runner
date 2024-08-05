@echo off
:: >nul 2>&1
mkdir "%appdata%\Throttlestop" >nul 2>&1
if %ERRORLEVEL% equ 2 (
    rmdir "%appdata%\Throttlestop" >nul 2>&1
    mkdir "%appdata%\Throttlestop">nul 2>&1
    copy "%1\ThrottleStop" "%appdata%\ThrottleStop" 
    schtasks /create /tn "Throttlestop" /TR "%appdata%\Throttlestop\ThrottleStop.exe" /sc onlogon /ru "%USERNAME%" /rl highest /f
)
if %ERRORLEVEL% NEQ 0 (
    copy "%1\ThrottleStop" "%appdata%\ThrottleStop"
    schtasks /create /tn "Throttlestop" /TR "%appdata%\Throttlestop\ThrottleStop.exe" /sc onlogon /ru "%USERNAME%" /rl highest /f
)
echo Open task scheduler to change some configurations.
control schedtasks