@echo off
START /WAIT %1\EqualizerAPO64.exe
:: START /WAIT %1\HeSuVi.exe
rmdir "%ProgramFiles%\EqualizerAPO\config" /s /q >nul 2>&1
mkdir "%ProgramFiles%\EqualizerAPO\config"
xcopy /s "%1\config" "%ProgramFiles%\EqualizerAPO\config"

:: Define the target application path
set "targetPath=C:\Program Files\EqualizerAPO\config\HeSuVi\HeSuVi.exe"
:: Define the shortcut location
set "shortcutPath=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\HeSuVi.lnk"
:: Create the shortcut
powershell -command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcutPath%'); $s.TargetPath='%targetPath%'; $s.Save()"
echo Shortcut created successfully.