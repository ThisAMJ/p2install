:: A batch file to achieve feature parity with the linux shell script
@echo off

set COMMONDIR=%~dp0
set GAMEROOT=%CD%
if "%COMMONDIR:~-1%" == "\" set "COMMONDIR=%COMMONDIR:~0,-1%"
if "%GAMEROOT:~-1%" == "\" set "GAMEROOT=%GAMEROOT:~0,-1%"

set GAMEPATH=%1
for /F "delims=" %%i in ("%CD%") do set GAME=%%~ni
if "%GAMEPATH:~-25%" == "Portal 2 Speedrun Mod" set GAME=Portal 2 Speedrun Mod


echo STEAM
echo %GAMEROOT%
echo %COMMONDIR%
echo %GAMEPATH%
echo %GAME%

set GAMEEXE=portal2.exe

set EXTRA_ARGS=-novid +mat_motion_blur_enabled 0 -background 4 -condebug -console -vulkan

:: WIP: Find Portal 2 location (appid 620) from Steam's libraryfolders.vdf
:: This is to fix gameinfo for aptag
set STEAM=C:\Program Files (x86)\Steam
for /F "usebackq tokens=* delims=" %%i in ("%STEAM%/steamapps/libraryfolders.vdf") do (
    set line=%%i
    :: Trim any *leading* whitespace and tabs
    set line=%line:~0,1%%line:~1%
    echo %line%
)

:: Repair gameinfo with p2common
if exist "%COMMONDIR%/.util/gameinfo/%GAME%.txt" (
    echo.
    echo Installing p2common...
    del /Q "%GAMEROOT%\%GAMEPATH%\gameinfo.txt"
    setlocal enabledelayedexpansion
    for /F "usebackq tokens=* delims=" %%i in ("%COMMONDIR%/.util/gameinfo/%GAME%.txt") do (
        set line="%%i"
        set line="!line:GAMEROOTGOESHERE=%GAMEROOT%!"
        set line="!line:COMMONDIRGOESHERE=%COMMONDIR%!"
        :: Remove the first and last 3 characters from the line (the silly quotes)
        set line=!line:~3,-3!
        echo.!line!>> "%GAMEROOT%/%GAMEPATH%/gameinfo.txt"
    )
    endlocal
)

if not exist "%COMMONDIR%/cfg" mkdir "%COMMONDIR%/cfg"
echo svar_set linux 0; svar_set windows 1 > "%COMMONDIR%/cfg/platform.cfg"

set ORIGINAL=%2
shift
shift
:loop
if "%1" == "" goto done
set ORIGINAL=%ORIGINAL% %1
shift
goto loop
:done

set DOING="%GAMEROOT%/%GAMEEXE%" -game %GAMEPATH% -steam %EXTRA_ARGS%

echo.
echo ARGS
echo ORIGINAL %ORIGINAL%
echo DOING... %DOING%
echo EXTRA %EXTRA_ARGS%
START "" %DOING%
