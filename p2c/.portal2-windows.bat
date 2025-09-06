@echo off
cls

set "DEBUG=0"
set "KILL=1"
set "VULKAN=1"

goto killtasks

:killtask
if "%KILL%"=="0" exit /B 0
tasklist /fi "ImageName eq %1" /fo csv 2>NUL | find /I "%1">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /IM %1 /F >NUL 2>&1
    set /A KILLED+=1
)
exit /B 0

:killtasks
SET "KILLED=0"
call :killtask DbgX.Shell.exe     &:: WinDbg
call :killtask hl.exe             &:: Half-Life
call :killtask hl2.exe            &:: Half-Life 2 / Portal
call :killtask portal2.exe        &:: Portal 2
call :killtask left4dead.exe      &:: Left 4 Dead
call :killtask left4dead2.exe     &:: Left 4 Dead 2
call :killtask infra.exe          &:: INFRA
call :killtask beginnersguide.exe &:: The Beginner's Guide
call :killtask beginnersguide.exe &:: The Beginner's Guide Crash Handler
call :killtask runme.exe          &:: Dark Messiah of Might and Magic Multi-Player
call :killtask mm.exe             &:: Dark Messiah of Might and Magic Single-Player

if %KILLED% GTR 0 (
    @REM Wait 200ms before launching to make sure the game is closed
    echo Waiting for processes to fully close...
    ping 127.0.0.1 -n 2 > NUL
)

set "COMMONDIR=%~dp0"
if "%COMMONDIR:~-1%" == "\" set "COMMONDIR=%COMMONDIR:~0,-1%"
set "GAMEROOT=%CD%"
if "%GAMEROOT:~-1%" == "\" set "GAMEROOT=%GAMEROOT:~0,-1%"
if "%GAMEROOT:~-4%" == "\bin" set "GAMEROOT=%GAMEROOT:~0,-4%"
set "GAMEPATH=%GAMEROOT%"
set "GAMEEXE=%~1"
for /F "delims=" %%i in ("%GAMEEXE%") do set "EXENAME=%%~ni"
if "%EXENAME:~-4%" == ".exe" set "EXENAME=%EXENAME:~0,-4%"
for /F "delims=" %%i in ("%GAMEROOT%") do set "GAMENAME=%%~ni"
set "SRCONFIGS="
if exist "%COMMONDIR%/srconfigs.txt" (
    set /P SRCONFIGS=<"%COMMONDIR%/srconfigs.txt"
)
if exist "%COMMONDIR%/srconfigs-windows.txt" (
    set /P SRCONFIGS=<"%COMMONDIR%/srconfigs-windows.txt"
)
call :fixgamename
goto n

:fixgamename
if "%GAMENAME%" == "aperture_ireland" set "GAMENAME=Aperture Ireland"
if "%GAMENAME%" == "aperturetag" set "GAMENAME=Aperture Tag"
if "%GAMENAME%" == "infra" set "GAMENAME=INFRA"
if "%GAMENAME%" == "left 4 dead" set "GAMENAME=Left 4 Dead"
if "%GAMENAME%" == "GarrysMod" set "GAMENAME=Garrys Mod"
exit /B

:n
set "GAMEARG=%EXENAME%"
set "EXTRA_ARGS=-novid +mat_motion_blur_enabled 0 -console"
setlocal enabledelayedexpansion
if exist "%COMMONDIR%\extra-args.txt" (
    for /F "usebackq delims=" %%i in ("%COMMONDIR%\extra-args.txt") do set "EXTRA_ARGS=!EXTRA_ARGS! %%i"
)
endlocal & set "EXTRA_ARGS=%EXTRA_ARGS%"
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
        if "!arg:\sourcemods\=!" neq "!arg!" (
            set "GAMEPATH=!arg!"
            set "GAMENAME=!arg:*\sourcemods\=!"
        )
        call :fixgamename
        @REM set "GAMEPATH=!arg!"
    ) else (
        set "EXTRA_ARGS=!EXTRA_ARGS! !arg!"
    )
)
endlocal & set "GAMENAME=%GAMENAME%" & set "GAMEARG=%GAMEARG%" & set "GAMEPATH=%GAMEPATH%" & set "EXTRA_ARGS=%EXTRA_ARGS%"

if "%GAMENAME%" == "unpack" (
    if "%GAMEARG%" == "hl2" set "GAMENAME=Half-Life 2"
    if "%GAMEARG%" == "portal" set "GAMENAME=Portal"
)

if "%VULKAN%" == "1" (
    set "EXTRA_ARGS=%EXTRA_ARGS% -vulkan"
)

if not exist "%GAMEROOT%\%GAMEARG%\" (
    if not exist "%GAMEARG%\" (
        set "GAMEARG="
    )
)

if exist "%COMMONDIR%\..\.util\.sar-build.txt" (
    del /s /q "%COMMONDIR%\..\.util\.sar-build.txt"
    set "DEBUG=1"
)

mkdir "%COMMONDIR%\..\.dirs"
rmdir "%COMMONDIR%\..\.dirs\%GAMENAME%"
del /a s "%COMMONDIR%\..\.dirs\%GAMENAME%" &:: Linux makes "system file" links
mklink /J "%COMMONDIR%\..\.dirs\%GAMENAME%" "%GAMEPATH%"
copy /Y "%COMMONDIR%\sar.pdb" "%GAMEROOT%"
@REM del /Q      "%GAMEARG%\console.log"        & mklink /H "%GAMEARG%\console.log"        "%COMMONDIR%\p2console.log"

:readsteam
set "P2PATH="
set "STEAM=C:\Program Files (x86)\Steam"
if exist "%COMMONDIR%/steam-location.txt" (
    for /F "usebackq delims=" %%i in ("%COMMONDIR%/steam-location.txt") do set "STEAM=%%i"
)
setlocal enabledelayedexpansion
if exist "%STEAM%/steamapps/libraryfolders.vdf" (
    for /F "usebackq delims="" tokens=*" %%i in ("%STEAM%/steamapps/libraryfolders.vdf") do (
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
if exist "%COMMONDIR%/../.util/gameinfo/%GAMENAME%.txt" (
    del /s /q "%GAMEARG%\gameinfo.txt"
)

set "MAIN_DIR="
set "SEARCHPATHS=0"
setlocal enabledelayedexpansion
for /F "usebackq tokens=* delims=" %%i in ("%COMMONDIR%/../.util/gameinfo/%GAMENAME%.txt") do (
    set "line=%%i"
    if "!line:SearchPaths=!" neq "!line!" set "SEARCHPATHS=1"
    set "line=!line:GAMEROOTGOESHERE=%GAMEROOT%!"
    set "line=!line:COMMONDIRGOESHERE=%COMMONDIR%!"
    set "line=!line:P2PATHGOESHERE=%P2PATH%!"
    echo.!line!>>"%GAMEARG%\gameinfo.txt"
    if "!line:Game=!" neq "!line!" (
        if "!SEARCHPATHS!" equ "1" (
            :: Remove comments (... attempt to remove comments)
            set "tmp=!line:*//=!"
            if "!tmp!" neq "!line!" (
                set "line=!!line:!tmp!=!!"
                set "line=!line:~0,-2!"
            )

            set "line=!line:*Game=!"
            set "line=!line:"=!\"
            for /F "tokens=*" %%a in ("!line!") do set "line=%%a"
            set "line=!line:|gameinfo_path|=%GAMEARG%\!"
            set "line=!line:\.\=\!"
            if "!MAIN_DIR!" equ "" (set "MAIN_DIR=!line!")
            if "!line:%COMMONDIR%=!" equ "!line!" (
                :: Remove game's cfg files that we have in common
                :: !line! is a folder, in which we want to rename the cfg files
                if exist "!line!\cfg" (
                    for /F "tokens=*" %%a in ('dir /b /s "!line!\cfg\*.cfg" ') do (
                        set "file=%%~nxa"
                        if exist "%COMMONDIR%\cfg\!file!" (
                            mkdir "!line!\cfg\.p2install-backup"
                            move /Y "!line!\cfg\!file!" "!line!\cfg\.p2install-backup\!file!"
                        )

                        if "%SRCONFIGS%" neq "" (
                            if exist "%SRCONFIGS%\cfg\!file!" (
                                mkdir "!line!\cfg\.p2install-backup"
                                move /Y "!line!\cfg\!file!" "!line!\cfg\.p2install-backup\!file!"
                            )
                        )
                    )
                )
            ) else (
                echo Game "%SRCONFIGS%">>"%GAMEARG%\gameinfo.txt"
            )
        )
    )
)
endlocal & set "MAIN_DIR=%MAIN_DIR%"

if not exist "%COMMONDIR%\cfg\" mkdir "%COMMONDIR%\cfg"

if exist "steam_appid.txt" (
    copy /Y "steam_appid.txt" "%COMMONDIR%\..\.util\.sar-appid.txt"
    if "%GAMENAME%" == "Thinking with Time Machine" (
        @REM TWTM's steam_appid.txt says 620, but it's actually 286080
        echo 286080 > "%COMMONDIR%\..\.util\.sar-appid.txt"
    )
)

:: TODO: Pack VPKs for DLCs
:: TODO: .util/saves/%GAMENAME% (same for maps)
:: TODO: Fix Reloaded mklinks (goes to portalreloaded instead of portal2 gamearg (first game path in gameinfo))

mkdir "%COMMONDIR%/cfg"
echo svar_set gameplatform Windows   > "%COMMONDIR%/cfg/platform.cfg"
echo svar_set linux 0               >> "%COMMONDIR%/cfg/platform.cfg"
echo svar_set windows 1             >> "%COMMONDIR%/cfg/platform.cfg"
echo svar_set macos 0               >> "%COMMONDIR%/cfg/platform.cfg"
echo svar_set gamearg "%GAMEARG%"   >> "%COMMONDIR%/cfg/platform.cfg"
echo svar_set gamename "%GAMENAME%" >> "%COMMONDIR%/cfg/platform.cfg"
echo svar_set username "%USERNAME%" >> "%COMMONDIR%/cfg/platform.cfg"

echo %date% %time% >> "%COMMONDIR%/p2install.log"
echo     PLATFORM: Windows >> "%COMMONDIR%/p2install.log"
echo     GAMEROOT: %GAMEROOT% ^(GAME %GAMEARG%^) >> "%COMMONDIR%/p2install.log"
echo      GAMEEXE: %GAMEEXE% >> "%COMMONDIR%/p2install.log"
echo INITIAL_ARGS: %* >> "%COMMONDIR%/p2install.log"
echo   EXTRA_ARGS: %EXTRA_ARGS% >> "%COMMONDIR%/p2install.log"
echo     GAMENAME: %GAMENAME% >> "%COMMONDIR%/p2install.log"
echo    COMMONDIR: %COMMONDIR% >> "%COMMONDIR%/p2install.log"
echo   FINAL_ARGS: "%GAMEEXE%" -game "%GAMEARG%" %EXTRA_ARGS% >> "%COMMONDIR%/p2install.log"
echo.>> "%COMMONDIR%/p2install.log"

if exist "%COMMONDIR%\cfg\p2install-extra.bat" (
    call "%COMMONDIR%\cfg\p2install-extra.bat"
)

START "" "%GAMEEXE%" -game "%GAMEARG%" %EXTRA_ARGS%

for /f "tokens=2" %%a in ('tasklist /nh /fi "imagename eq %EXENAME%.exe"') do set "PID=%%a"
if "%DEBUG%" == "1" (
    if defined PID if "%PID%" neq "" (
        echo Attaching WinDBG to %EXENAME%.exe with PID %PID% >> "%COMMONDIR%/p2install.log"
        start /max windbgx -g -G -p %PID% -debugArch amd64
    ) else (
        echo Could not find PID for %EXENAME%.exe >> "%COMMONDIR%/p2install.log"
    )
    echo.>> "%COMMONDIR%/p2install.log"
)
