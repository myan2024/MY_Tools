@echo off
setlocal enabledelayedexpansion

echo --- Initializing Software Check ---


:: 1 CHECK AND START APPS (skips if already running)
call :CheckAndStart "Weixin.exe" "C:\Program Files (x86)\Tencent\Weixin\Weixin.exe"
call :CheckAndStart "QQ.exe" "D:\Program Files\QQNT\QQ.exe"
REM call :CheckAndStart "OUTLOOK.EXE" "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
REM call :CheckAndStart "ONENOTE.EXE" "C\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE"


:: 2 HANDEL NON-EXE FILES(URLs/HTML)
echo Opening Favorites...
start "" "C:\MY_Work\MY_Favorites\CMD_URLs.html"

:: 3 RUN JAVA CODE(Maintains this window)
echo.
echo Lauching Java Application: Idle...
:: java "C:\MY_Work\MY_Software\IDLE\Idle"
:: Change directory to where the file is
cd /d "C:\MY_Work\MY_Software\IDLE"s
:: Run the class "Idle" from the current directory (.)
java -cp . Idle

:: --- HELPER FUNCTION ---
:CheckAndStart
tasklist /FI "IMAGENAME EQ %~1" 2>NUL | FIND /I "%~1" >NUL
if %ERRORLEVEL% equ 0 (
    echo [SKIPPED] %~1 is already running.
) else (
    echo [STARTING] %~1 ...
    START "" "%~2"
)

goto :eof