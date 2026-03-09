@echo off
REM Define the drive letter and the network path
SET DRIVE_LETTER=Z:
SET NETWORK_PATH=\\TRUENAS\Shared\
REM Optional: set username and password if different from the current login
SET USERNAME_TRUNAS=TRUENAS\myan
SET PASSWORD=1q2w3e

REM Check if the drive letter is already mapped
NET USE | FIND "%DRIVE_LETTER%" >nul
IF %ERRORLEVEL% EQU 0 (
    echo %DRIVE_LETTER% is already mapped. Proceeding...
) ELSE (
    REM If not mapped, attempt to map the drive
    echo Mapping %DRIVE_LETTER% to %NETWORK_PATH%...
    REM Use the following line for simple mapping:
    REM net use %DRIVE_LETTER% %NETWORK_PATH% /persistent:yes
    REM Use the following line if credentials are required (uncomment and replace variables):
    net use %DRIVE_LETTER% %NETWORK_PATH% %PASSWORD% /user:%USERNAME%  /persistent:yes
    
    REM Check if the mapping was successful
    IF %ERRORLEVEL% EQU 0 (
        echo Successfully mapped %DRIVE_LETTER%.
    ) ELSE (
        echo Failed to map %DRIVE_LETTER%. Error code: %ERRORLEVEL%
    )
)

:END
pause