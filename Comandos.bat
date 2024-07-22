@echo off
:: Enable color support and setting colors
call :SetColors

cd "c:\Users\%USERNAME%\AppData\Local\WindowsOptmizer" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	echo Error on acess the scripts on AppData, run the Setup to fix this.
	pause
	exit		
)

:: Check Administrator Privileges
net.exe session >nul 2>&1
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
setlocal EnableDelayedExpansion
:: Definir o nome do arquivo de texto
set "arquivo=c:\Users\%USERNAME%\AppData\Local\WindowsOptmizer\scripts.txt"

REM Variável para armazenar os scripts
set "scripts="

REM Ler o arquivo linha por linha
for /f "tokens=*" %%a in (%arquivo%) do (
    set "scripts=!scripts!%%a|"
)

REM Converter para um array separado por '|'
set "scripts=!scripts:~0,-1!"

REM Definir o delimitador para '|' (pipe)
set "delimitador=|"

REM Converter para um array usando o delimitador
set i=0
for %%a in (!scripts!) do (
    set "script[!i!]=%%a"
    set /a i+=1
)

REM Exibir opções para o usuário
echo Escolha um script para abrir:
echo [0] !script[0]!
echo [1] !script[1]!

REM Ler a escolha do usuário
set /p escolha="Digite o número da opção desejada: "

REM Executar o script escolhido, se válido
if "%escolha%" equ "0" (
     !script[0]!
) else if "%escolha%" equ "1" (
    call !script[1]!
) else (
    echo Opção inválida.
)

pause
:MainMenu

echo. 1 - teste
echo.

set /p input=Put your input here: 
echo %input%
if /i %input% equ 1 goto rON
if /i %input% equ 2 goto res
::ELSE
echo Invalid Input 

:rON

:res

pause










::-----------Functions------------::

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
exit /b