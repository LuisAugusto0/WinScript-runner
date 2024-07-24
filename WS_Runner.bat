@echo off

:: Set initial variables
call :SetVariables
call :SetColors

::-----------------------------Startup-Verifications-----------------------------::
:: - Verify if the files exists and the administratos privileges to define which ::
::      menu will show to the user                                               ::
::-------------------------------------------------------------------------------::
SETLOCAL EnableDelayedExpansion
:: Check Administrator Privileges
net session >nul 2>&1
set AdminTest=%ERRORLEVEL%

::Check if files exists
cd "%StartDir%" >nul 2>&1
set FolderTest=%ERRORLEVEL%     

set FilesTest=0
if not exist %ModulesFile% (
    set FilesTest+=1
) else (
    for /f "tokens=*" %%a in (%ModulesFile%) do (
        if not exist %StartDir%\%%a%ScriptsNamesSufix% ( set FilesTest+=1 )
    )
)

if not exist %MenusFile% set FilesTest+=1

@REM if not exist %PathFile% (
@REM     call :SplashAscii
@REM     set FilesTest+=1
@REM ) else (
@REM     call :SplashAsciiNoStop
@REM     set /a i=0
@REM     :: Read archive lines
@REM     for /f "tokens=*" %%a in (%PathFile%) do (
@REM         set "OldPath[!i!]=%%a"
@REM         set /a i+=1
@REM     )
@REM     set /a i-=1
@REM )




if %FolderTest% neq 0 (
    if %AdminTest% neq 0 ( 
        call :SplashAscii
        goto InitialSetup 
    ) else (
        echo %white%Open without Admin to the initial setup
        goto end
    )
	:: Running a new tab in Admin and closing actual flow
    exit
) else (
    @REM ::reset variables to the correct path (read in the PathFile)
    @REM call :ResetVariables
    if %FilesTest% equ 0 (
        if %AdminTest% neq 0 (
            goto AdminChoice
        ) else (
            call :SplashAscii
            goto MainMenu
        )
    ) else (
        goto InitialSetup
    )
)

:AdminChoice
    cls
    call :SplashAsciiNoStop
    echo Do you want to enter the setup menu?
    echo %YELLOW%[%WHITE%1%YELLOW%] - %GREEN%yes	%YELLOW%[%WHITE%2%YELLOW%] - %RED%no
    set /p input=%WHITE%- Option: 
    if /i "%input%" equ "1" goto ModifySetup 
    if /i "%input%" equ "2" goto OpenAdmin
    ::else
    call :inputMissmatch %input%
    goto AdminChoice

:OpenAdmin
    @REM echo %NL%%white%Opening with admin rights...
    @REM timeout 2 > nul
    powershell -Command "Start-Process %cd%\WS_Runner.bat -Verb RunAs"
	exit /b 0
::--------------------------------END-Startup------------------------------------::

:MainMenu
    cls 
    :MainMenuAscii

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
    if /i "%input%" LEQ "%i%" goto ScriptMenu
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

:ScriptMenu
    setlocal EnableDelayedExpansion
    :: Array to store the scritps names 
    set "script="
    set /a j=0
    :: Read archive lines
    for /f "tokens=*" %%a in (%StartDir%/!module[%input%]!%ScriptsNamesSufix%) do (
        set "script[!j!]=%%a"
        set /a j+=1
    )

    set /a j-=1
    :: Show option to the use r
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
        call inputMissmatch %escolha%
    )
    goto MainMenu


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

::-------------------------------SETUP---------------------------------::
:: - Acessible only without admin (because running in admin, the       ::
::      actual dir change to System32, loosing track of the real dir)  ::
:: - Create, update and deleate the auxiliar files in Appdata          ::
::---------------------------------------------------------------------::

:InitialSetup
    cls
    call :SetupAscii
    echo %BLUE%╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
    echo %BLUE%║%WHITE% Error accessing the auxiliar files in AppData. Do you want to create a new folder?		   	%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%1%YELLOW%] - %GREEN%Create folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%2%YELLOW%] - %RED%Exit												%BLUE%║
    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%- Option: 
    if /i "%input%" equ "1" goto creating
    if /i "%input%" equ "2" goto end
    call :inputMissmatch %input%
    goto AdminChoice

:ModifySetup
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
    if /i "%input%" equ "4" goto end
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
    mkdir "%AsciiDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%AsciiDir%' created" "creation of '%AsciiDir%'"
    mkdir "%MenusDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%MenusDir%' created" "creation of '%MenusDir%'"
    xcopy /s ".\scripts" "%ScriptsDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of scripts made" "copy of the scripts"
    xcopy /s ".\menus" "%MenusDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of menus made" "copy of the menus"
    copy ".\asciiArts" "%AsciiDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of ascii arts made" "copy of the ascii arts"
    dir /b "%MenusDir%" > "%MenusFile%"
    @REM dir /B | find /V ".txt" "%MenusDir%" > "%MenusFile%"
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%MenusFile%' created" "creation of '%MenusFile%'"
    dir /b "%ScriptsDir%" > "%ModulesFile%"
    @REM dir /B | find /V ".txt" "%ScriptsDir%" > "%ModulesFile%"
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "'%ModulesFile%' created" "creation of '%ModulesFile%'"
    for /f "tokens=*" %%a in (%ModulesFile%) do (
        dir /b "%ScriptsDir%\%%a" > "%StartDir%\%%a%ScriptsNamesSufix%"
        @REM dir /B | find /V ".txt" "%ScriptsDir%\%%a" > "%StartDir%\%%a%ScriptsNamesSufix%"
        set /A bugs+=!ERRORLEVEL!
        call :CommandMensage !ERRORLEVEL! "'%StartDir%\%%a%ScriptsNamesSufix%' created" "creation of '%StartDir%\%%a%ScriptsNamesSufix%'"
    )

    if !bugs! EQU 0 (
        echo %GREEN% Folder created with success
    ) else (
        echo %RED% !bugs! errors during creation of the folder
    )
    endlocal
    pause>nul|set/p =%WHITE%Press any key to continue...
    goto ModifySetup


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
    )
    goto InitialSetup
    
:uninstall
    rmdir /s /q "%StartDir%" >nul 2>&1
    goto end

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
	pause

::---------------------------------------------------------------------::
::------------------------------END-SETUP------------------------------::
::---------------------------------------------------------------------::

:end
    pause>nul|set/p =%WHITE%Press any key to close program...
    exit
:: Style functions

:SplashAscii
echo %BLUE%
@REM for /f "tokens=*" %%a in (%AsciiDir%\splashFull.txt) do ( echo %%a )
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
echo ║			╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝	%CYAN%V %Version%%BLUE%			║
echo ║													║
echo ║ %CYAN%Made by LuisAugusto0 (GitHub)%BLUE%										║
echo ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝                       
pause>nul|set/p =%CYAN%Press any key to start...
exit /b 0

:SplashAsciiNoStop
echo %BLUE%
@REM for /f "tokens=*" %%a in (%AsciiDir%\splashFull.txt) do ( echo %%a )
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
echo ║			╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝	%CYAN%V %Version%%BLUE%			║
echo ║													║
echo ║ %CYAN%Made by LuisAugusto0 (GitHub)%BLUE%										║
echo ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝                          
exit /b 0

:SetupAscii
echo %BLUE%
for /f "tokens=*" %%a in (.\asciiArts\setup.txt) do ( echo %%a )
echo %WHITE%
exit /b 0

:MainMenuAscii
echo %BLUE%
for /f "tokens=*" %%a in (%AsciiDir%\menu.txt) do ( echo %%a )
echo %WHITE%
exit /b 0

:inputMissmatch
cls
echo Input '%1' does not correspond to any option in menu, try typing again
timeout 4 > nul
exit /b 0

::SET

:SetColors
:: Color and other ascii support config
chcp 65001 >nul 2>&1
mode con lines=100 cols=140
title WindowScript Setup
for /f "tokens=*" %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"
:: Colors
set BLACK=%ESC%[30m
set RED=%ESC%[31m
set GREEN=%ESC%[32m
set YELLOW=%ESC%[33m
set BLUE=%ESC%[34m
set MAGENTA=%ESC%[35m
set CYAN=%ESC%[36m
set WHITE=%ESC%[37m
@REM set BRIGHT_BLACK=%ESC%[90m
@REM set BRIGHT_RED=%ESC%[91m
@REM set BRIGHT_GREEN=%ESC%[92m
@REM set BRIGHT_YELLOW=%ESC%[93m
@REM set BRIGHT_BLUE=%ESC%[94m
@REM set BRIGHT_MAGENTA=%ESC%[95m
@REM set BRIGHT_CYAN=%ESC%[96m
@REM set BRIGHT_WHITE=%ESC%[97m
exit /b 0

:: Common variables
:SetVariables
set "AuxArqSufix=.txt"
set "StartDir=c:\Users\%USERNAME%\AppData\Local\WinscriptRunner"
set "ScriptsDir=%StartDir%\scripts"
set "MenusDir=%StartDir%\menus"
set "AsciiDir=%StartDir%\asciiArts"
set "ModulesFile=%StartDir%\modules%AuxArqSufix%"
set "MenusFile=%StartDir%\menus%AuxArqSufix%"
set "PathFile=%StartDir%\initialPath%AuxArqSufix%"
set "ScriptsNamesSufix=_names%AuxArqSufix%"
set "RunSufix=.bat"
set "Version=0.21"
set "Input=0"

@REM :ResetVariables
@REM set "ScriptsDir=!OldPath[0]!\scripts"
@REM set "MenusDir=!OldPath[0]!\menus"
@REM set "AsciiDir=!OldPath[0]!\commonFiles"

:: Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%
exit /b 0