@echo off
call elev-macro.bat
%$elev% calc "cmd /k whoami /priv"