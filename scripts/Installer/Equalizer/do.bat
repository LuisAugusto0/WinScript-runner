@echo off
START /WAIT %1\EqualizerAPO64.exe
:: START /WAIT %1\HeSuVi.exe
rmdir "%ProgramFiles%\EqualizerAPO\config" /s /q >nul 2>&1
mkdir "%ProgramFiles%\EqualizerAPO\config"
xcopy /s "%1\config" "%ProgramFiles%\EqualizerAPO\config"

:: Define the target application path
set targetPath="C:\Program Files\EqualizerAPO\config\HeSuVi\HeSuVi.exe"
:: Define the shortcut location
set shortcutPath="%appdata%\Microsoft\Windows\Start Menu\Programs\Equalizer APO 1.3.2\HeSuVi.lnk"
:: Create the shortcut
@REM powershell -command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcutPath%'); $s.TargetPath='%targetPath%'; $s.Save()"
:: Modify the shortcut to run as administrator
powershell -command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcutPath%'); $s.TargetPath='%targetPath%'; $s.IconLocation='%targetPath%'; $s.Description='HeSuVi'; $s.WorkingDirectory='%~dp0'; $s.Arguments=''; $s.WindowStyle=1; $s.; $s.Save(); "
echo Shortcut created successfully.