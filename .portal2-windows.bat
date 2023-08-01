@echo off
cls

set "COMMONDIR=%~dp0"
set "GAMEROOT=%CD%"
set "GAMEPATH=%GAMEROOT%"
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
        set "SOURCEMOD=1"
        set "SOURCEMOD_OF=%GAMENAME%"
        set "SOURCEMOD_OF_PATH=%GAMEROOT%"
        set "GAMEARG=!arg!"
        set "GAMENEXT=0"
        if "!arg:\sourcemods\=!" neq "!arg!" set "GAMENAME=!arg:*\sourcemods\=!"
        set "GAMEPATH=!arg!"
    ) else (
        set "EXTRA_ARGS=!EXTRA_ARGS! !arg!"
    )
)
endlocal & set "GAMENAME=%GAMENAME%" & set "GAMEARG=%GAMEARG%" & set "EXTRA_ARGS=%EXTRA_ARGS%"

mkdir "%COMMONDIR%\.dirs"
rmdir       "%COMMONDIR%\.dirs\%GAMENAME%" & mklink /J "%COMMONDIR%\.dirs\%GAMENAME%" "%GAMEPATH%"
rmdir /Q /S "%GAMEARG%\crosshair"          & mklink /J "%GAMEARG%\crosshair"          "%COMMONDIR%\.util\crosshair"
rmdir /Q /S "%GAMEROOT%\ihud"              & mklink /J "%GAMEROOT%\ihud"              "%COMMONDIR%\.util\ihud"
del /Q      "%GAMEARG%\console.log"        & mklink /H "%GAMEARG%\console.log"        "%COMMONDIR%\p2console.log"

:readsteam
set "P2PATH="
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
                set "P2PATH=!line!\steamapps\common\Portal 2"
            )
        )
    )
) else (
    endlocal
    cls
    echo ERROR: Could not find Steam installation.
    echo Please create a file called steam-location.txt in the same directory as portal2.bat
    echo and put the path to your Steam installation in it. ^(e.g. C:\Program Files ^(x86^)\Steam^)
    echo Once done, press any key to continue...
    pause > nul
    goto readsteam
)
endlocal & set "P2PATH=%P2PATH%"

if "%P2PATH%" == "" (
    cls
    echo ERROR: Could not find Portal 2. Is it installed via Steam?
    echo Launch will abort. Press any key to acknowledge.
    pause > nul
    exit /B
)

:: Repair gameinfo with p2common
if exist "%COMMONDIR%/.util/gameinfo/%GAMENAME%.txt" (
    del /Q "%GAMEARG%\gameinfo.txt"
    setlocal enabledelayedexpansion
    for /F "usebackq tokens=* delims=" %%i in ("%COMMONDIR%/.util/gameinfo/%GAMENAME%.txt") do (
        set "line=%%i"
        set "line=!line:GAMEROOTGOESHERE=%GAMEROOT%!"
        set "line=!line:COMMONDIRGOESHERE=%COMMONDIR%!"
        set "line=!line:P2PATHGOESHERE=%P2PATH%!"
        echo.!line!>>"%GAMEARG%\gameinfo.txt"
    )
    endlocal
)

:: TODO: Remove game's cfg files that we have in common
:: TODO: Pack VPKs for DLCs
:: TODO: .util/saves/%GAMENAME% (same for maps)
:: TODO: Fix Reloaded mklinks (goes to portalreloaded instead of portal2 gamearg (first game path in gameinfo))

mkdir "%COMMONDIR%/cfg"
echo "svar_set gameplatform Windows"     > "%COMMONDIR%/cfg/platform.cfg"
echo "svar_set linux 0"                 >> "%COMMONDIR%/cfg/platform.cfg"
echo "svar_set windows 1"               >> "%COMMONDIR%/cfg/platform.cfg"
echo "svar_set macos 0"                 >> "%COMMONDIR%/cfg/platform.cfg"
echo "svar_set gamearg ""%GAMEARG%"""   >> "%COMMONDIR%/cfg/platform.cfg"
echo "svar_set gamename ""%GAMENAME%""" >> "%COMMONDIR%/cfg/platform.cfg"

echo "%date% %time%" >> "%COMMONDIR%/p2install.log"
echo "    PLATFORM: Windows"                     >> "%COMMONDIR%/p2install.log"
echo "    GAMEROOT: %GAMEROOT% (GAME %GAMEARG%)" >> "%COMMONDIR%/p2install.log"
echo "     GAMEEXE: %GAMEEXE%"                   >> "%COMMONDIR%/p2install.log"
echo "INITIAL_ARGS: %*"                          >> "%COMMONDIR%/p2install.log"
echo "  EXTRA_ARGS: %EXTRA_ARGS%"                >> "%COMMONDIR%/p2install.log"
echo "    GAMENAME: %GAMENAME%"                  >> "%COMMONDIR%/p2install.log"
echo "   COMMONDIR: %COMMONDIR%"                 >> "%COMMONDIR%/p2install.log"
echo "" >> "%COMMONDIR%/p2install.log"

START "" "%GAMEEXE%" -game "%GAMEARG%" %EXTRA_ARGS%
