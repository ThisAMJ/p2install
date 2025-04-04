@echo off
@REM To use, put the following in Portal2SpeedrunMod/COPY.bat
@REM call "[path to]/p2install/.util/.smsm-copy.bat"

@REM .util - p2install
set "COMMONDIR=%~dp0"
if "%COMMONDIR:~-1%" == "\" set "COMMONDIR=%COMMONDIR:~0,-1%"
set "COMMONDIR=%COMMONDIR%\.."

SET "binary=smsm.dll"
SET "src=smsm\bin\%binary%"
SET "vpk=%COMMONDIR%\.dirs\Portal 2\bin\vpk.exe"

set "dest=C:\Program Files (x86)\Steam\steamapps\sourcemods\Portal 2 Speedrun Mod"
mkdir "%dest%"

set "KILL=1" &:: Kill existing processes and relaunch
set "COPY=0" &:: Copy instead of move
cd ../..
goto install

:killtask
if "%KILL%"=="0" exit /B 0
tasklist /fi "ImageName eq %1" /fo csv 2>NUL | find /I "%1">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /IM %1 /F >NUL 2>&1
    set /A KILLED+=1
    echo.	 %1
)
exit /B 0

:install
echo Killing existing processes...
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
call :killtask stanley.exe        &:: The Stanley Parable
call :killtask runme.exe          &:: Dark Messiah of Might and Magic Multi-Player
call :killtask mm.exe             &:: Dark Messiah of Might and Magic Single-Player
call :killtask swarm.exe          &:: Alien Swarm

if ("%COPY%" == "1") (
    echo Copying SMSM to mod directory...
    echo copy /Y "%src%" "%dest%\%binary%"
    copy /Y "%src%" "%dest%\%binary%"
) else (
    echo Moving SMSM to mod directory...
    echo move /Y "%src%" "%dest%\%binary%"
    move /Y "%src%" "%dest%\%binary%"
)

echo SMSM built and installed!

echo.
echo ====== Copying raw files... ======
echo Copying cfg...
xcopy /Q /E /V /Y /I "cfg" "%dest%\cfg"
echo Copying maps...
xcopy /Q /E /V /Y /I "maps" "%dest%\maps"
echo Copying resource...
xcopy /Q /E /V /Y /I "resource" "%dest%\resource"
echo Copying scripts...
xcopy /Q /E /V /Y /I "scripts" "%dest%\scripts"
echo Copying media...
xcopy /Q /E /V /Y /I "media" "%dest%\media"
echo Copying gameinfo...
copy /Y "gameinfo.txt" "%dest%\gameinfo.txt"

echo.
echo ====== Packing pak01_dir... ======
"%vpk%" pak01_dir
copy /Y "pak01_dir.vpk" "%dest%\pak01_dir.vpk"
DEL pak01_dir.vpk

echo Done.
exit /B 0
