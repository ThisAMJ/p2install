#!/bin/bash
:<<"::CMDLITERAL"
GOTO :CMDSCRIPT
::CMDLITERAL
/bin/bash $(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/.portal2-linux.sh "$@"
exit $?
:CMDSCRIPT
@REM "%ProgramFiles%\Git\git-bash.exe" "%~dp0.portal2-linux.sh" %*
CALL "%~dp0.portal2-windows.bat" %*
EXIT /B
