#!/bin/bash
:<<"::CMDLITERAL"
GOTO :CMDSCRIPT
::CMDLITERAL
/bin/bash $(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/p2c/.portal2-linux.sh "$@"
exit $?
:CMDSCRIPT
@REM "%ProgramFiles%\Git\git-bash.exe" "%~dp0.portal2-linux.sh" %*
CALL "%~dp0p2c/.portal2-windows.bat" %*
EXIT /B
