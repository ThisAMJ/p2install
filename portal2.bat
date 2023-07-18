#!/bin/bash
:<<"::CMDLITERAL"
GOTO :CMDSCRIPT
::CMDLITERAL
clear
/bin/bash $(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/portal2-linux.sh "$@"
exit $?
:CMDSCRIPT
CLS
CALL "%~dp0portal2-windows.bat" %*
EXIT /B
