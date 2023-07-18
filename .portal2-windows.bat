@echo off
cls

set "COMMONDIR=%~dp0"
set "GAMEROOT=%CD%"
set "GAMEEXE=%~1"
for /F "delims=" %%i in ("%CD%") do set "GAMENAME=%%~ni"
if "%COMMONDIR:~-1%" == "\" set "COMMONDIR=%COMMONDIR:~0,-1%"
if "%GAMEROOT:~-1%" == "\" set "GAMEROOT=%GAMEROOT:~0,-1%"

set "GAMEARG=portal2"
set "EXTRA_ARGS=-novid +mat_motion_blur_enabled 0 -background 5 -condebug -console" &:: -vulkan
if exist "%COMMONDIR%extra-args.txt" (
    for /F "usebackq delims=" %%i in ("%COMMONDIR%extra-args.txt") do set "EXTRA_ARGS=%%i"
)
set "FIRSTARG=1"
setlocal enabledelayedexpansion
for %%a in (%*) do (
    set "arg=%%~a"
    if "!FIRSTARG!" == "1" (
        set "FIRSTARG=0"
    ) else if "!arg!" == "-game" (
        set "GAMENEXT=1"
    ) else if "!GAMENEXT!" == "1" (
        set "GAMEARG=!arg!"
        set "GAMENEXT=0"
        if "!arg:\sourcemods\=!" neq "!arg!" set "GAMENAME=!arg:*\sourcemods\=!"
    ) else (
        set "EXTRA_ARGS=!EXTRA_ARGS! !arg!"
    )
)
endlocal & set "GAMENAME=%GAMENAME%" & set "GAMEARG=%GAMEARG%" & set "EXTRA_ARGS=%EXTRA_ARGS%"

:readsteam
set "P2DIR="
set "STEAM=C:\Program Files (x86)\Steam"
if exist "%COMMONDIR%/steam-location.txt" (
    for /F "usebackq delims=" %%i in ("%COMMONDIR%/steam-location.txt") do set "STEAM=%%i"
)
setlocal enabledelayedexpansion
if exist "%STEAM%/steamapps/libraryfolders.vdf" (
    for /F usebackq^ delims^=^"^ tokens^=* %%i in ("%STEAM%/steamapps/libraryfolders.vdf") do (
        set "line=%%i"
        set "line=!line:*"=!     "
        if "!line:~0,4!" == "path" (
            set "line=!line:~5,-5!"
            set "line=!line:*"=!"
            set "line=!line:"=!"
            set "line=!line:^T=!"
            set "line=!line:\\=\!"
            if exist "!line!\steamapps\common\Portal 2" (
                set "P2DIR=!line!\steamapps\common\Portal 2"
            )
        )
    )
) else (
    endlocal
    echo ERROR: Could not find Steam installation.
    echo Please create a file called steam-location.txt in the same directory as portal2.bat
    echo and put the path to your Steam installation in it. ^(e.g. C:\Program Files ^(x86^)\Steam^)
    echo Once done, press any key to continue...
    pause > nul
    goto readsteam
)
endlocal & set "P2DIR=%P2DIR%"

if "%P2DIR%" == "" (
    echo ERROR: Could not find Portal 2. Is it installed via Steam?
    echo Launch will abort. Press any key to acknowledge.
    pause > nul
    exit /B
)

:: Repair gameinfo with p2common
if exist "%COMMONDIR%/.util/gameinfo/%GAMENAME%.txt" (
    del /Q "%GAMEROOT%\%GAMEARG%\gameinfo.txt"
    setlocal enabledelayedexpansion
    for /F "usebackq tokens=* delims=" %%i in ("%COMMONDIR%/.util/gameinfo/%GAMENAME%.txt") do (
        set "line=%%i"
        set "line=!line:GAMEROOTGOESHERE=%GAMEROOT%!"
        set "line=!line:COMMONDIRGOESHERE=%COMMONDIR%!"
        set "line=!line:P2DIRGOESHERE=%P2DIR%!"
        echo.!line!>> "%GAMEROOT%/%GAMEARG%/gameinfo.txt"
    )
    endlocal
)

:: TODO: Remove Portal Reloaded's / TWTM's default autoexec.cfg if we have a common one
:: TODO: Pack VPKs for DLCs

if not exist "%COMMONDIR%/cfg" mkdir "%COMMONDIR%/cfg"
echo svar_set linux 0; svar_set windows 1 > "%COMMONDIR%/cfg/platform.cfg"

echo.Playing %GAMENAME% (gamedir %GAMEARG%)
echo.Extra args: %EXTRA_ARGS%
START "" "%GAMEEXE%" -game "%GAMEARG%" %EXTRA_ARGS%
