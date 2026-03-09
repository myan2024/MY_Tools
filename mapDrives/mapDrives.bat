@echo off
setlocal enabledelayedexpansion

REM Header: Start with @echo off to prevent command echoing, providing a cleaner output.
REM Use :: or rem (remark) to add comments that do not execute.
REM Variables: Defined using set var=value and accessed using %var%
:: set: Sets environment variables.
:: set /a: Performs arithmetic operations.
:: No Spaces in Assignment: set Var=Value should not have spaces around the = sign.
REM Input/Output: Use echo [message] to display text and set /p var=Prompt: to take user input.
REM Execution: Commands run sequentially. Use pause to keep the window open after completion.
REM Loops/Logic: Use IF for conditional logic and FOR for loops (use %%a in files, %a in console). 
:: if, goto: Control flow statements.


:: Call the function for your 3 drives
:: Syntax: call :MapDrive [DriveLetter] [Path] [Username] [Password]
call :MapDrive Z: "\\TRUENAS\Shared\" 
call :MapDrive M: "\\192.168.0.201\myan"
call :MapDrive K: "\\192.168.0.200\kt" "kt"

echo All mapping attempts complete.
pause
goto :eof

REM create a function to map drives
:MapDrive
:: 1. Capture arguments
set "DRIVE=%~1"
set "URL=%~2"
set "USER=%~3"
set "PASS=%~4"

:: Strip trailing backslash if it exists because \ escapes the next character
if "%URL:~-1%"=="\" set "URL=%URL:~0,-1%"
:: %URL:~-1% is a substring command that extracts the last character of the variable URL.
:: %URL:~0,-1% extracts the entire string except for the very last character.

:: 2. Set Default Values if arguments are missing
if "%USER%"=="" set "USER=myan"
if "%PASS%"=="" set "PASS=1q2w3e"

:: 2. Extract Server Name from URL (extracts "Server" from "\\Server\Shared")
for /f "tokens=1 delims=\" %%a in ("%URL%") do set "SERVER=%%a"
:: for /f: This command is used to process and parse text.
:: tokens=1: Instructs the script to only grab the first part (the first token) created by that split.
:: delims=\: Tells the script to use the backslash (\) as the "divider" to split the text into parts.
:: %%a: This is a temporary variable that holds the extracted text during the loop.
:: in ("%URL%"): This specifies the input string to be parsed.

:: 3. Prefix User with Server Name
set "FULL_USER=%SERVER%\%USER%"

:: 3. Check if drive already exists
if exist %DRIVE%\ (
    echo [SKIP] %DRIVE% is already mapped.
    goto :eof
)

:: --- DEBUG SECTION ---
echo.
echo DEBUG: Preparing to run the following command:
echo net use %DRIVE% "%URL%" %PASS% /user:%FULL_USER% /persistent:yes
echo.
:: ---------------------

:: 4. Map the drive
echo Mapping %DRIVE% to %URL% as %FULL_USER%...
net use %DRIVE% "%URL%" %PASS% /user:%FULL_USER% /persistent:yes >nul 2>&1

:: 5. Check for errors
if %errorlevel% equ 0 (
    echo [OK] Successfully mapped %DRIVE%.
) else (
    echo [ERROR] Failed to map %DRIVE%. Check path or credentials.
)
goto :eof
