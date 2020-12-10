@echo off
mode con:cols=50 lines=30
Title Backup

echo ===================
echo Proceed for Backup?
echo ===================
Pause

set count=0

if %TIME:~0,2% LSS 10 (set Hour=0%TIME:~1,1%) ELSE (set Hour=%TIME:~0,2%)
set TimeStart=%Hour%.%TIME:~3,2%.%TIME:~6,2%
echo Started : %date% %TimeStart%

set BACKUPLOG=F:\BackupData
REM set BACKUPLOG=%cd%

if not exist "%BACKUPLOG%" (
echo No Backup location was found
echo %Backup% not available
pause
end)

MKDIR %BACKUPLOG%\Backup_%date%-[%TimeStart%]
set BACKUPLOG=%BACKUPLOG%\Backup_%date%-[%TimeStart%]

:DISPATCH
echo %count%
if %count%==0 goto MUSIC
if %count%==1 goto DOCUMENTS
if %count%==2 goto DONE

:MUSIC
set DOMAIN=Music
set /a count=%count%+1
REM set INPUTDIR="C:\Users\Xavier\Music\iTunes\iTunes Media\Music"
REM set OUTPUTDIR="F:\Musique\iTunes\iTunes Media\Music"
set INPUTDIR="%cd%\1"
set OUTPUTDIR="%cd%\2"
goto COPYMIR

:DOCUMENTS
set DOMAIN=Documents
set /a count=%count%+1
set INPUTDIR="C:\Users\Xavier\Documents"
REM set OUTPUTDIR="F:\Desktop"
REM set INPUTDIR="%cd%"
set OUTPUTDIR="%cd%\3"
goto COPY

:COPY
Title Backing up %DOMAIN% (%count%/3)
robocopy %INPUTDIR% %OUTPUTDIR% /E /XA:SH /W:1 /R:100 /ETA /TEE /XJ /X /V > "%BACKUPLOG%\Backup_%date%-[%TimeStart%]-%DOMAIN%.log"
goto DISPATCH

:COPYMIR
Title Backing up %DOMAIN% (%count%/3)
robocopy %INPUTDIR% %OUTPUTDIR% /MIR /W:1 /R:100 /ETA /TEE /XJ /X /V > "%BACKUPLOG%\Backup_%date%-[%TimeStart%]-%DOMAIN%.log"
goto DISPATCH

:DONE

pause
cls
echo.
Title Backup Done
echo.
echo ===============================
if %TIME:~0,2% LSS 10 (set Hour=0%TIME:~1,1%) ELSE (set Hour=%TIME:~0,2%)
set TimeEnd=%Hour%.%TIME:~3,2%.%TIME:~6,2%
echo Started   : %date% %TimeStart%
echo Completed : %date% %TimeEnd%
echo ===============================
echo.
echo Log folder saved at "%BACKUPLOG%"
echo.

pause 

RMDIR %OUTPUTDIR%
RMDIR "%BACKUPLOG%\Backup_%date%-[%TimeStart%]-%DOMAIN%.log"

exit
