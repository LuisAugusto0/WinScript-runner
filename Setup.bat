@echo off

:: Set variables
call :SetVariables
call :SetColors

:: Set console properties
chcp 65001 >nul 2>&1
mode con lines=100 cols=140
title WindowScript Setup

::Check if folder exists
cd "%StartDir%" >nul 2>&1
set AUX=%ERRORLEVEL%

:: Check Administrator Privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :SplashAscii
    if %AUX% neq 0 goto FileNotExistsMenu 
    ::ELSE
    goto FileExistsMenu 
	:: Running a new tab in Admin and closing actual flow
    exit
) else echo Run without admin rights && goto end


:: Methods

:FileNotExistsMenu
    cls
    call :SetupAscii
    echo %BLUE%╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
    echo %BLUE%║%WHITE% Error accessing the scripts in AppData. Do you want to create a new folder?				%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%1%YELLOW%] - %GREEN%Create folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%2%YELLOW%] - %RED%Exit												%BLUE%║
    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%- Option: 
    if /i "%input%" equ "1" goto creating
    goto end

:FileExistsMenu
    cls
    call :SetupAscii
    echo %BLUE%╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
    echo %BLUE%║%WHITE% What do you want to do?										%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%1%YELLOW%] - %WHITE%Remove folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%2%YELLOW%] - %WHITE%Update folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%3%YELLOW%] - %WHITE%Run program											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%4%YELLOW%] - %WHITE%Exit												%BLUE%║
    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%- Option: 
    if /i "%input%" equ "1" goto removing
    if /i "%input%" equ "2" goto removingAndCreating
    if /i "%input%" equ "3" goto run
    goto end


:creating
    setlocal enabledelayedexpansion
    set /A bugs=0
    mkdir "%StartDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%StartDir%' created" "creation of '%StartDir%'"
    mkdir "%ScriptsDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%ScriptsDir%' created" "creation of '%ScriptsDir%'"
    xcopy /s ".\scripts" "%ScriptsDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of scripts made" "copy of the scripts"
    mkdir "%MenusDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%MenusDir%' created" "creation of '%MenusDir%'"
    xcopy /s ".\menus" "%MenusDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of menus made" "copy of the menus"
    copy "./WinScript.bat" "%MenusDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    dir /b "%MenusDir%" > "%MenusFile%"
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%MenusFile%' created" "creation of '%MenusFile%'"
    dir /b "%ScriptsDir%" > "%ModulesFile%"
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%ModulesFile%' created" "creation of '%ModulesFile%'"
    echo %MyPath% > "%PathFile%"
    call :CommandMensage !ERRORLEVEL! "'%PathFile%' created" "creation of '%PathFile%'"
    set /A bugs+=!ERRORLEVEL!
    for /f "tokens=*" %%a in (%ModulesFile%) do (
        dir /b "%ScriptsDir%\%%a" > "%StartDir%\%%a%ScriptsNamesSufix%"
        set /A bugs+=!ERRORLEVEL!
        call :CommandMensage !ERRORLEVEL! "'%StartDir%\%%a%ScriptsNamesSufix%' created" "creation of '%StartDir%\%%a%ScriptsNamesSufix%'"
    )

    @REM dir /B "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts\*.bat" > "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts.txt"

    if !bugs! EQU 0 (
        echo %GREEN% Folder created with success
    ) else (
        echo %RED% !bugs! errors during creation of the folder
        goto end
    )
    endlocal
    pause>nul|set/p =%WHITE%Press any key to continue...
    goto FileExistsMenu


:removing
    rmdir /s /q "%StartDir%" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %GREEN% Folder deleted with success
        pause>nul|set/p =%WHITE%Press any key to continue...
    ) else if %ERRORLEVEL% EQU 2 (
        echo %GREEN% Folder deleted with success
        pause>nul|set/p =%WHITE%Press any key to continue...
    ) else (
        echo %RED% An error occurred during the deletion
        goto end
    )
    goto FileNotExistsMenu
    

:removingAndCreating
    rmdir /s /q "%StartDir%" >nul 2>&1
    @REM if %ERRORLEVEL% EQU 0 (
    @REM     echo %GREEN% Folder deleted with success
    @REM ) else if %ERRORLEVEL% EQU 2 (
    @REM     echo %GREEN% Folder deleted with success
    @REM ) else (
    @REM     echo %RED% An error occurred during the deletion
    @REM )
    call :CommandMensage !ERRORLEVEL! "'%StartDir%' and subdir deleted" "deletion of '%StartDir%'"
    goto creating

:CommandMensage
    if %1 equ 0 (
        echo %GREEN%%~2 with success
    ) else (
        echo %RED%An error occurred during the %~3
    )
    exit /b 0
:run
	powershell -Command "Start-Process ./Comandos.bat -Verb RunAs"
    exit

:end
    pause>nul|set/p =%WHITE%Press any key to close program...
    exit

:: Style functions

:SplashAscii
echo %BLUE%
@REM for /f "tokens=*" %%a in (%CommonDir%\splashFull.txt) do ( echo %%a )
echo ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo ║													║
echo ║													║  
echo ║		██╗    ██╗██╗███╗   ██╗███████╗ ██████╗██████╗ ██╗██████╗ ████████╗			║
echo ║		██║    ██║██║████╗  ██║██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝			║
echo ║		██║ █╗ ██║██║██╔██╗ ██║███████╗██║     ██████╔╝██║██████╔╝   ██║  			║ 
echo ║		██║███╗██║██║██║╚██╗██║╚════██║██║     ██╔══██╗██║██╔═══╝    ██║ 			║  
echo ║		╚███╔███╔╝██║██║ ╚████║███████║╚██████╗██║  ██║██║██║        ██║ 			║  
echo ║		 ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝  			║ 
echo ║													║
echo ║			██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗  				║
echo ║			██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗				║
echo ║			██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝				║
echo ║			██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗				║
echo ║			██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║				║
echo ║			╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝				║
echo ║													║
echo ║ %CYAN%Made by LuisAugusto0 (GitHub)%BLUE%										║
echo ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝                       
pause>nul|set/p =%CYAN%Press any key to start the Setup...
exit /b 0

:SetupAscii
echo %BLUE%
for /f "tokens=*" %%a in (%CommonDir%\setup.txt) do ( echo %%a )
echo %WHITE%
exit /b 0


::SET

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

:: Common variables
:SetVariables
set "AuxArqSufix=.txt"
set "StartDir=c:\Users\%USERNAME%\AppData\Local\WinscriptRunner"
set "ScriptsDir=%StartDir%\scripts"
set "MenusDir=%StartDir%\menus"
set "ModulesFile=%StartDir%\modules%AuxArqSufix%"
set "MenusFile=%StartDir%\menus%AuxArqSufix%"
set "PathFile=%StartDir%\initialPath%AuxArqSufix%"
set "ScriptsNamesSufix=_names%AuxArqSufix%"
set "MyPath=%cd%"
set "CommonDir=%MyPath%\commonFiles"

:: Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%
exit /b 0