@echo off
cls
setlocal

rem To use this script, update this variable to be correct for your system
set "gmodbin=F:\SteamLibrary\SteamApps\common\GarrysMod\bin"

echo Amber's gmod addon build script version 1.0
if not exist "%gmodbin%" (
    echo To use this script you must edit the gmodbin variable to be correct for your system
    goto end
)
if exist "%~dp0output\ttt_gravity_gun.gma" (
    del "%~dp0output\ttt_gravity_gun.gma"
    echo Deleted previous build
)
echo Attempting to use %gmodbin%\gmad.exe
cd /d "%gmodbin%"
"gmad.exe" create -folder "%~dp0src" -out "%~dp0output\ttt_gravity_gun.gma"
if not exist "%~dp0output\ttt_gravity_gun.gma" (
    echo Something went wrong, addon was not built
)
goto end

:end
endlocal
@echo on
pause
