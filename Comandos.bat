@echo off
:: Enable color support and setting colors
call :SetColors

:: Set variables
set "StartDir=c:\Users\%USERNAME%\AppData\Local\WindowsOptmizer"
set "ScriptDir=%StartDir%\scripts"
set "NamesFile=%StartDir%\scripts.txt"
set "ExecFile="

cd %StartDir% >nul 2>&1
if %ERRORLEVEL% neq 0 (
	echo Error on acess the scripts on AppData, run the Setup to fix this.
	pause
	exit		
)

:: Check Administrator Privileges
net session >nul 2>&1
if %ERRORLEVEL% equ 0 (
	:: Running a new tab in Admin and closing actual flow
	echo %RED% Enable Administrator to this tool work as intended 
	pause
	powershell -Command "Start-Process ./Comandos.bat -Verb RunAs"
	exit /b 1
) else (
	echo  %GREEN% Administrator privileges concedded, ready to start
	pause
)

:MenuSetup

:MainMenu
setlocal EnableDelayedExpansion
:: Array to store the scritps names 
set "script="
set /a i=0
:: Read archive lines
echo %NamesFile%
for /f "tokens=*" %%a in (%NamesFile%) do (
    set "script[!i!]=%%a"
	set /a i+=1
)
set /a i-=1

:: Show option to the user
echo Choose a script to open
for /L %%a in (0,1,!i!) do call echo %%a - %%script[%%a]%%


:: Read option and execute script if is valid
set /p escolha="Option: "
if /i "%escolha%" LEQ "%i%" (
	set ExecFile=%ScriptDir%\!script[%escolha%]!
	call :RunScript !ExecFile!
) else ( 
	echo Invalid option
)


pause
exit

::-----------Functions------------::

:RunScript
echo Running script %1
:: Read and execute each line of the script
for /f "tokens=*" %%a in (%1) do (
    %%a
    if !ERRORLEVEL! neq 0 (
        exit /b 1
    )
)
exit /b 0

:: Color support
:SetColors
for /f "tokens=*" %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"
set BLACK=%ESC%[30m
set RED=%ESC%[31m
set GREEN=%ESC%[32m
set YELLOW=%ESC%[33m
set BLUE=%ESC%[34m
set MAGENTA=%ESC%[35m
set CYAN=%ESC%[36m
set WHITE=%ESC%[37m
set BRIGHT_BLACK=%ESC%[90m
set BRIGHT_RED=%ESC%[91m
set BRIGHT_GREEN=%ESC%[92m
set BRIGHT_YELLOW=%ESC%[93m
set BRIGHT_BLUE=%ESC%[94m
set BRIGHT_MAGENTA=%ESC%[95m
set BRIGHT_CYAN=%ESC%[96m
set BRIGHT_WHITE=%ESC%[97m
exit /b 0