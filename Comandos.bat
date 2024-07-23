@echo off
:: Enable color support and setting colors
call :SetColors

:: Set variables
set "AuxArqSufix=.txt"
set "StartDir=c:\Users\%USERNAME%\AppData\Local\WinscriptRunner"
set "ScriptDir=%StartDir%\scripts"
set "ModulesFile=%StartDir%\modules%AuxArqSufix%"
@REM set "DataDir=%StartDir%\data"
set "ScriptsNamesSufix=_names%AuxArqSufix%"
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
	echo Enable Administrator to this tool work as intended 
	pause
	powershell -Command "Start-Process ./Comandos.bat -Verb RunAs"
	exit /b 1
) else (
	echo  Administrator privileges concedded, ready to start
	pause
)


:MenuModules
setlocal EnableDelayedExpansion
:: Array to store the scritps names 
set "module="
set /a i=0
:: Read archive lines
echo %ModulesFile%
for /f "tokens=*" %%a in (%ModulesFile%) do (
    set "module[!i!]=%%a"
	set /a i+=1
)
set /a i-=1
set Exit=%j%+1

:: Show option to the user
echo Choose a module to open
for /L %%a in (0,1,!i!) do call echo %%a - %%module[%%a]%%


set /p input="Option: "
if /i "%input%" LEQ "%i%" (	
	call :MainMenu %StartDir% %ScriptDir% !module[%input%]! %ScriptsNamesSufix%
) 
if /i "%input%" EQU "%Exit%"( 
	goto end
) else (
	echo Invalid option
)




::-----------Functions------------::

@REM :RunScript
:: Read and execute each line of the script
@REM for /f "tokens=*" %%a in (%1) do (
@REM     %%a
@REM     if !ERRORLEVEL! neq 0 (
@REM         exit /b 1
@REM     )
@REM )
@REM call %1
@REM exit /b 0

:MainMenu
setlocal EnableDelayedExpansion
:: Array to store the scritps names 
set "script="
set /a j=0
:: Read archive lines
for /f "tokens=*" %%a in (%1/%3%4) do (
    set "script[!j!]=%%a"
	set /a j+=1
)

set /a j-=1
:: Show option to the user
echo Choose a script to open
for /L %%a in (0,1,!j!) do call echo %%a - %%script[%%a]%%
set Exit=%j%+1

:: Read option and execute script if is valid
set /p escolha="Option: "
if /i "%escolha%" LEQ "%j%" (
	set ExecDir=%2\%3\!script[%escolha%]!
	echo Running script %ExecDir%
	call :MenuScript !ExecDir!
) 
if /i "%escolha%" equ "%Exit%" (
	:MenuModules_options
) else ( 
	echo Invalid option
	exit /b 1
)
exit /b 0


:MenuScript
echo run script or not?
set /p escolha="Option: "
echo %1
if /i %escolha% equ 0 ( 
	call %1\undo.bat
	exit /b 0
)
if /i %escolha% equ 1 ( 
	call %1\do.bat 
	exit /b 0
)
exit /b 1

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