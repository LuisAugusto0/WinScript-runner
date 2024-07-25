@echo off

:: Set initial variables
call :SetVariables
call :SetColors

::-----------------------------Startup-Verifications-----------------------------::
:: - Verify if the files exists and the administrator privileges to define which ::
::      menu will show to the user                                               ::
::-------------------------------------------------------------------------------::
:Verifications
SETLOCAL EnableDelayedExpansion
:: Check Administrator Privileges
net session >nul 2>&1
set AdminTest=%ERRORLEVEL%

::Check if files exists
cd "%StartDir%" >nul 2>&1
set FolderTest=%ERRORLEVEL%   

cd "%AsciiDir%" >nul 2>&1
set FilesTest=%ERRORLEVEL%  

if not exist %ModulesFile% (
    set FilesTest+=1
) else (
    for /f "tokens=*" %%a in (%ModulesFile%) do (
        if not exist %StartDir%\%%a%ScriptsNamesSufix% ( set FilesTest+=1 )
    )
)

if not exist %MenusFile% set FilesTest+=1


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
    echo %BLUE%╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
    echo %BLUE%║%WHITE% Do you want to enter the setup menu?	    	        		    				%BLUE%║
    echo %BLUE%║%YELLOW% [%WHITE%0%YELLOW%] - %WHITE%No	%YELLOW% [%WHITE%1%YELLOW%] - %WHITE%Yes 										%BLUE%║
    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%:
    if /i "%input%" equ "0" goto OpenAdmin
    if /i "%input%" equ "1" goto ModifySetup 
    ::else
    call :inputMissmatch %input%
    goto AdminChoice

:OpenAdmin
    @REM echo %white%Opening with admin rights...
    @REM timeout 2 > nul
    powershell -Command "Start-Process %cd%\WS_Runner.bat -Verb RunAs"
	exit /b 0
::-------------------------------------------------------------------------------::
::--------------------------------END-Startup------------------------------------::
::-------------------------------------------------------------------------------::

::---------------------------------Main-Menu-------------------------------------::
:: - Redirect to all the modules and scripts                                     ::
:: - Run the scripts                                                             ::
::-------------------------------------------------------------------------------::

:MainMenu
    setlocal EnableDelayedExpansion
    cls 
    call :MainMenuAscii
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    echo %YELLOW% "%CYAN%Main menu%YELLOW%"
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    :: Array to store the scritps names 
    set "module="
    set /a i=1
    :: Read archive lines
    for /f "tokens=*" %%a in (%ModulesFile%) do (
        set "module[!i!]=%%a"
        set /a i+=1
    )
    set /a i-=1


    :: Show option to the user
    echo   !YELLOW![!WHITE!%Exit%!YELLOW!] -!WHITE! Exit program
    echo   !YELLOW![!WHITE!r!YELLOW!] -!WHITE! Restore point
    echo  ---------------------------
    for /L %%a in (1,1,!i!) do call echo   !YELLOW![!WHITE!%%a!YELLOW!] - !WHITE!%%module[%%a]%%


    set /p inputM=%WHITE%: 
    if /i "%inputM%" EQU "%Exit%" ( 
        goto end
    ) else if /i "%inputM%" EQU "r" (
        goto RestoreMenu
    ) else if /i "%inputM%" LEQ "%i%" (
        goto ModuleMenu
    ) else (
        call :inputMissmatch %inputM%
        goto MainMenu
    )

:RestoreMenu
    cls
    call :RestorePointAscii
    echo   !YELLOW![!WHITE!%Exit%!YELLOW!] - %WHITE%Go back to Main Menu
    echo  -----------------------------------
    echo  !YELLOW![!WHITE!1!YELLOW!] -!WHITE! Create a Restore point
    echo  !YELLOW![!WHITE!2!YELLOW!] -!WHITE! Use a Restore point
    set /p input=%WHITE%: 
    if /i "%input%" EQU "%Exit%" ( 
        goto MainMenu
    ) else if /i "%input%" EQU "1" (
        goto CreateRestore
    ) else if /i "%input%" LEQ "2" (
        goto UseRestore
    ) else (
        call :inputMissmatch %input%
        goto MainMenu
    )

:CreateRestore
    ::Enable Restore points and create restore points
    chcp 437 >nul 2>&1
    powershell -NoProfile Enable-ComputerRestore -Drive 'C:\'>nul 2>&1
    Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "RPSessionInterval" /f  >nul 2>&1
    Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "DisableConfig" /f >nul 2>&1
    Reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
    %b%
    powershell -Command "Checkpoint-Computer -Description 'Windows Script Runner Restore Point' -RestorePointType 'MODIFY_SETTINGS'" 
    chcp 65001 >nul 2>&1
    goto MainMenu


:UseRestore
    cls
    rstrui.exe
    goto MainMenu

:ModuleMenu
    setlocal EnableDelayedExpansion
    cls
    call :ModuleAscii
    :: Array to store the scritps names 
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    echo  %CYAN%Main menu /%YELLOW% "%CYAN%!module[%inputM%]!%YELLOW%"
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    set "script="
    set /a j=1
    :: Read archive lines
    for /f "tokens=*" %%a in (%StartDir%/!module[%inputM%]!%ScriptsNamesSufix%) do (
        set "script[!j!]=%%a"
        set /a j+=1
    )

    Set ActualModule=!module[%inputM%]!
    set /a j-=1
    :: Show option to the user
    echo  %WHITE%Choose a module to open

    call echo   !YELLOW![!WHITE!%Exit%!YELLOW!] - %WHITE%Go back to Main Menu
    call echo   !YELLOW![!WHITE!a!YELLOW!] - %WHITE%Run all scripts
    call echo  -----------------------------------
    for /L %%a in (1,1,!j!) do ( 
        call :PrintAuxiliarArchive !script[%%a]! "title.txt" "!YELLOW![!WHITE!%%a!YELLOW!] - !WHITE!%1" "T"
    )

    

    :: Read option and execute script if is valid
    set /p input=%WHITE%: 
    if /i "%input%" equ "%Exit%" (
        goto MainMenu
    ) else if /i "%input%" LEQ "%j%" (
        call :ScriptMenu %ScriptsDir%\%ActualModule%\!script[%input%]! !script[%input%]! 
        goto ModuleMenu
    ) else if /i "%input%" equ "a" (
        goto RunAllMenu
    ) else ( 
        call :inputMissmatch %input%
        goto ModuleMenu
    )
    goto MainMenu

:RunAllMenu
    setlocal EnableDelayedExpansion
    cls
    call :ModuleAscii
    :: Array to store the scritps names 
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    echo  %CYAN%Main menu /%YELLOW% "%CYAN%!module[%inputM%]!%YELLOW%"
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    echo  %WHITE%Choose what to do
    echo   !YELLOW![!WHITE!0!YELLOW!] - %WHITE%Go back
    echo   !YELLOW![!WHITE!1!YELLOW!] - %WHITE%Run all scripts without confirmation
    echo   !YELLOW![!WHITE!2!YELLOW!] - %WHITE%Undo all scripts without confirmation
    echo   !YELLOW![!WHITE!3!YELLOW!] - %WHITE%Run/Undo all scripts with confirmation
    set /p input=%WHITE%: 
    if /i "%input%" equ "0" (
        goto ModuleMenu
    ) else if /i "%input%" equ "1" (
        for /L %%a in (0,1,!j!) do ( 
            if exist %ScriptsDir%\%ActualModule%\!script[%%a]!\do.bat ( 
                call %ScriptsDir%\%ActualModule%\!script[%%a]!\do.bat
                call :ScriptErrorHandler %ERRORLEVEL% %2         
            ) else (
                echo Script !script[%%a]! doesn't have a do.bat file
            )
        )
    ) else if /i "%input%" equ "2" (
        for /L %%a in (0,1,!j!) do ( 
            if exist %ScriptsDir%\%ActualModule%\!script[%%a]!\undo.bat ( 
                call %ScriptsDir%\%ActualModule%\!script[%%a]!\undo.bat
                call :ScriptErrorHandler %ERRORLEVEL% %2         
            ) else (
                echo Script !script[%%a]! doesn't have a undo.bat file
            )
        )
    ) else if /i "%input%" equ "3" (
        for /L %%a in (0,1,!j!) do ( 
            call :ScriptMenu %ScriptsDir%\%ActualModule%\!script[%input%]! !script[%input%]!        
        )
    ) 

    pause>nul|set/p =%WHITE%Press any key to go back...
    goto MainMenu

:ScriptMenu
    cls
    call :ScriptAscii
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════
    if exist %1\title.txt (
        for /f "tokens=*" %%b in (%1\title.txt) do (
            echo  %CYAN%Main menu / !module[%inputM%]! /%YELLOW% "%CYAN%%%b%YELLOW%"
        )
    ) else (
        %CYAN%Main menu / !module[%inputM%]! /%YELLOW% "%CYAN%%2%YELLOW%"
    )
    echo %BLUE%═════════════════════════════════════════════════════════════════════════════════════════════════════════

    echo %BLUE% ╔══════════════╗
    echo %BLUE% ║ %WHITE%Description: %BLUE%║
    echo %BLUE% ╚══════════════╝
    call :PrintAuxiliarArchive %2 "description.txt" "There is no description" "D"
    echo  -------------------------------------------------------------------------------------------------------

    if exist %1\do.bat (
        goto ScriptMenuAux
    ) else (
        echo %RED%Broken%WHITE%, do.bat does not exist.
        exit /b 0
    )
    
    :endScript
    pause>nul|set/p =%WHITE%Press any key to go back...
    exit /b 0

:ScriptMenuAux
    if exist %1\undo.bat (
        goto WithUndo
    ) else (
        goto WithoutUndo
    )
 
    

    pause>nul|set/p =%WHITE%Press any key to go back...
    goto endTest

:WithUndo
    echo %YELLOW% [%WHITE%0%YELLOW%]%WHITE% Go back to modules
    echo  ---------------------------
    echo %YELLOW% [%WHITE%1%YELLOW%]%WHITE% Do
    echo %YELLOW% [%WHITE%2%YELLOW%]%WHITE% Undo		
    
    set /p Aux=%WHITE%:
    
    cls
    if /i "%Aux%" equ "1" ( 
        call %1\do.bat
        call :ScriptErrorHandler %ERRORLEVEL% %2\do.bat
    ) else if /i "%Aux%" equ "2" ( 
        call %1\undo.bat 
        call :ScriptErrorHandler %ERRORLEVEL% %2\undo.bat
    ) else if /i "%Aux%" equ "0" (
        goto ModuleMenu
    ) else (
        call :inputMissmatch %Aux%
        goto endScript
    )
    
    goto endScript

:WithoutUndo
        echo %RED% Caution%WHITE%: this Script does not have a undo option
        echo  -------------------------------------------------------------------------------------------------------
        echo %YELLOW% [%WHITE%0%YELLOW%]%WHITE% Go back to Modules
        echo %YELLOW% [%WHITE%1%YELLOW%]%WHITE% Run
        set /p input=%WHITE%:
        cls
        if /i "%input%" equ "1" ( 
            call %1\do.bat
        ) else if /i "%input%" equ "0" ( 
            goto ModuleMenu
        ) else (
            call :inputMissmatch %input%
            goto endScript
        )
    
    goto endScript


:PrintAuxiliarArchive
    if exist %ScriptsDir%\%ActualModule%\%1\%~2 (
        call :PrintModule %ScriptsDir%\%ActualModule%\%1\%~2 %4
    ) else (
        if %4 equ "T" (
            call echo   %WHITE%%~3%1
        ) else (
            call echo   %WHITE%%~3
        )
    )
    exit /b 0

:PrintModule
    if %2 equ "T" (
        for /f "tokens=*" %%b in (%1) do (
            call echo   !YELLOW![!WHITE!%%a!YELLOW!] - %WHITE%%%b 
        )
    ) else if %2 equ "D" (
        for /f "tokens=*" %%b in (%1) do (
            call echo    %WHITE%%%b
        )
    ) else (
        echo %RED%Error in the code, some PrintAuxiliarArchive call have the wrong code in the last parameter.
        echo Parameter %2 does not exist
    )
    
    exit /b 0

:ScriptErrorHandler
    if %1 equ 0 (
        echo %GREEN%Script %2 executed succesfull 
    ) else if %ERRORLEVEL% equ 1 (
        echo %GREEN%Script %2 executed, %RED%but generated a error code 1.
        echo Problably have a Incorrect funcion. Fix the incorrect function or put "exit \b" on the end of script to remove this error
    ) else if %ERRORLEVEL% equ 9009 (
        echo %RED%Script %2 closed with error code 9009, because of a line that isn't a command
    ) else (
        echo %RED%An error occurred with Script %2. Error code: %ERRORLEVEL%
    )
    exit /b 0
::-----------------------------------------------------------------------------::
::-------------------------------END-MAIN-MENU---------------------------------::
::-----------------------------------------------------------------------------::

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
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%0%YELLOW%] - %RED%Exit												%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%1%YELLOW%] - %GREEN%Create folder											%BLUE%║
    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%: 
    if /i "%input%" equ "1" goto creating
    if /i "%input%" equ "0" goto end
    call :inputMissmatch %input%
    goto AdminChoice

:ModifySetup
    cls
    call :SetupAscii
    echo %BLUE%╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗
    echo %BLUE%║%WHITE% What do you want to do?										%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%0%YELLOW%] - %WHITE%Exit												%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%1%YELLOW%] - %WHITE%Update folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%2%YELLOW%] - %WHITE%Remove folder											%BLUE%║
    echo %BLUE%║%WHITE% %YELLOW%[%WHITE%3%YELLOW%] - %WHITE%Run program											%BLUE%║

    echo %BLUE%╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝
    set /p input=%WHITE%: 
    if /i "%input%" equ "1" goto removingAndCreating
    if /i "%input%" equ "2" goto removing
    if /i "%input%" equ "3" goto OpenAdmin
    if /i "%input%" equ "0" goto end
    goto end


:creating
    cls
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
    xcopy /s ".\scripts" "%ScriptsDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of scripts made" "copy of the scripts"
    copy ".\asciiArts" "%AsciiDir%" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    call :CommandMensage !ERRORLEVEL! "Copy of ascii arts made" "copy of the ascii arts"
    call :CommandMensage !ERRORLEVEL! "'%MenusFile%' created" "creation of '%MenusFile%'"
    dir /b "%ScriptsDir%" > "%ModulesFile%"
    @REM dir /B | find /V ".txt" "%ScriptsDir%" > "%ModulesFile%"        Comando para remover .txt dos diretorios listados, mas não funcion
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
    cls
    rmdir /s /q "%StartDir%" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %GREEN% Folder deleted with success
    ) else if %ERRORLEVEL% EQU 2 (
        echo %GREEN% Folder deleted with success
    ) else if %ERRORLEVEL% EQU 5 (
        echo %RED% The %ERRORLEVEL% error occurred during the deletion, trying to delete with admin rights...
        echo rmdir /s /q @echo off"%StartDir%" > "%cd%/tmp.bat"
        powershell "Start-Process %cd%\tmp.bat -Verb RunAs"
        del %cd%\tmp.bat
        pause>nul|set/p =%WHITE%Press any key to continue...
    ) else (
        echo %RED% The %ERRORLEVEL% error occurred during the deletion
        pause>nul|set/p =%WHITE%Press any key to continue...
    )
    pause>nul|set/p =%WHITE%Press any key to continue...
    goto InitialSetup
    
:uninstall
    rmdir /s /q "%StartDir%" >nul 2>&1
    goto end

:removingAndCreating
    rmdir /s /q "%StartDir%" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %GREEN% Folder deleted with success
    ) else if %ERRORLEVEL% EQU 2 (
        echo %GREEN% Folder deleted with success
    ) else if %ERRORLEVEL% EQU 5 (
        echo %RED% The %ERRORLEVEL% error occurred during the deletion, trying to delete with admin rights...
        echo rmdir /s /q @echo off"%StartDir%" > "%cd%/tmp.bat"
        powershell "Start-Process %cd%\tmp.bat -Verb RunAs"
        del %cd%\tmp.bat
        pause>nul|set/p =%WHITE%Press any key to continue...
    ) else (
        echo %RED% The %ERRORLEVEL% error occurred during the deletion
        pause>nul|set/p =%WHITE%Press any key to continue...
    )
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

:ErrorAscii
echo %BLUE%
for /f "tokens=*" %%a in (%AsciiDir%\splash.txt) do ( echo %%a )   
echo %WHITE%                   
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

:ModuleAscii
echo %BLUE%
for /f "tokens=*" %%a in (%AsciiDir%\modules.txt) do ( echo %%a )
echo %WHITE%
exit /b 0

:ScriptAscii
echo %BLUE%
for /f "tokens=*" %%a in (%AsciiDir%\splash.txt) do ( echo %%a )
echo %WHITE%
exit /b 0

:RestorePointAscii
echo %BLUE%
for /f "tokens=*" %%a in (%AsciiDir%\restore.txt) do ( echo %%a )
echo %WHITE%
exit /b 0

:inputMissmatch
cls
call :ErrorAscii
echo Input '%1' does not correspond to any option in menu
pause > nul|set/p =%WHITE%Press any key and try again...
exit /b 0

::SET

:SetColors
:: Color and other ascii support config
chcp 65001 >nul 2>&1
mode con lines=60 cols=140
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
set "StartDir=c:\WinscriptRunner"
set "ScriptsDir=%StartDir%\scripts"
set "AsciiDir=%StartDir%\asciiArts"
set "ModulesFile=%StartDir%\modules%AuxArqSufix%"
set "MenusFile=%StartDir%\menus%AuxArqSufix%"
set "PathFile=%StartDir%\initialPath%AuxArqSufix%"
set "ScriptsNamesSufix=_names%AuxArqSufix%"
set "RunSufix=.bat"
set "Version=1.01"
set /a input=0
set /a Exit=0

@REM :: Creating a Newline variable (the two blank lines are required!)
@REM set NLM=^


@REM set NL=^^^%NLM%%NLM%^%NLM%%NLM%
exit /b 0