@echo off

::Check if folder exists
cd "c:\Users\%USERNAME%\AppData\Local\WindowsOptmizer" >nul 2>&1
set AUX=%ERRORLEVEL%
:: Check Administrator Privileges
net session >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    if %AUX% neq 0 goto FileNotExistsMenu 
    ::ELSE
    goto FileExistsMenu 
	:: Running a new tab in Admin and closing actual flow
    exit
) else echo Run without admin rights && goto end


:FileNotExistsMenu
    echo Error accessing the scripts in AppData. Do you want to create a new folder?
    echo [1] - Create folder
    echo [2] - Exit
    set /p input=Option: 
    if /i "%input%" equ "1" goto creating
    goto end

:FileExistsMenu
    echo Scripts folder already exists. What do you want to do?
    echo [1] - Remove folder
    echo [2] - Update folder
    echo [3] - Run program
    echo [4] - Exit
    set /p input=Option: 
    if /i "%input%" equ "1" goto removing
    if /i "%input%" equ "2" goto removingAndCreating
    if /i "%input%" equ "3" goto run
    goto end




:creating
    setlocal enabledelayedexpansion
    set /A bugs=0
    mkdir "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    mkdir "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!
    copy ".\scripts" "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts" >nul 2>&1
    set /A bugs+=!ERRORLEVEL!

    dir /B "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts\*.bat" > "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts.txt"

    if !bugs! EQU 0 (
        echo Folder created with success
    ) else (
        echo An error occurred during creation of the folder
        goto end
    )
    endlocal
    goto runMenu


:removing
    rmdir /s /q "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer" >nul 2>&1
    echo %ERRORLEVEL%
    if %ERRORLEVEL% EQU 0 (
        echo Folder deleted with success
    ) else if %ERRORLEVEL% EQU 2 (
        echo Folder deleted with success
    ) else (
        echo An error occurred during the deletion
    )
    goto end

:removingAndCreating
    rmdir /s /q "C:\Users\%USERNAME%\AppData\Local\WindowsOptmizer" >nul 2>&1
    goto creating

    

:runMenu
    echo Do you want to run the program now?
    echo [1] - yes
    echo [2] - no
    set /p input=Option: 
    if /i %input% neq 1 goto end

:run
	powershell -Command "Start-Process ./Comandos.bat -Verb RunAs"
    exit
:end
    echo Type any key to close program...
    pause >nul 2>&1
    exit