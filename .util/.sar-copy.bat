@echo off
@REM To use, put the following in SourceAutoRecord/copy.bat
@REM call "[path to]/p2install/.util/.sar-copy.bat"

set "COMMONDIR=%~dp0"
if "%COMMONDIR:~-1%" == "\" set "COMMONDIR=%COMMONDIR:~0,-1%"
SET "COMMONDIR=%COMMONDIR%\..\p2c"

SET "binary=sar.dll"
SET "src=bin\%binary%"

set "KILL=1" &:: Kill existing processes and relaunch
set "COPY=0" &:: Copy instead of move
cd ..
goto install

:killtask
if "%KILL%"=="0" exit /B 0
tasklist /fi "ImageName eq %1" /fo csv 2>NUL | find /I "%1">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /IM %1 /F >NUL
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
call :killtask runme.exe          &:: Dark Messiah of Might and Magic Multi-Player
call :killtask mm.exe             &:: Dark Messiah of Might and Magic Single-Player

if ("%COPY%" == "1") (
    echo Copying SAR to common directory...
    copy /Y "%src%" "%commondir%\%binary%"
) else (
    echo Moving SAR to common directory...
    move /Y "%src%" "%commondir%\%binary%"
)

set /p appid=<"%commondir%\..\.util\.sar-appid.txt"
if "%appid%"=="" set appid=620

if %KILLED% GTR 0 (
    @REM Wait 200ms before launching to make sure the game is closed
    echo Waiting for processes to fully close...
    ping 127.0.0.1 -n 2 > NUL
)

echo SAR built and installed!
if "%KILL%"=="1" (
    echo Restarting the game ^(appid %appid%^)...
    start "" "steam://rungameid/%appid%"
) else (
    echo Done!
)
