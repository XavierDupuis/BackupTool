@echo off
mode con:cols=100 lines=20
Title Backup

echo.
echo ===================================================================================================
echo =============          Proceed for Backup? (Default Backup Drive set to F:\)          =============
echo ===================================================================================================
echo.
Pause

:: SETTING COUNT OF DOMAINS
set count=0

:: SETTING BACKUP LOCATION AND LOG FOLDER LOCATION
set DRIVE=F
set BACKUPFOLDER=%DRIVE%:\!BACKUPDATA
set BACKUPLOG=%BACKUPFOLDER%\!LOGS
REM set BACKUPFOLDER=%cd%
REM set BACKUPLOG=%cd%

:: CONFIRM BACKUP LOCATION && PROMPT RETRYING
:DRIVEEXIST
if exist "%BACKUPFOLDER%" (
	goto BEGIN) ELSE (
	cls
	echo.
	echo No Backup location was found
	echo %BACKUPFOLDER:~0,3% drive not available
	echo.
	goto NEWDRIVE)
:NEWDRIVE
echo [Enter new drive letter]
set /p DRIVE=
set BACKUPFOLDER=%DRIVE%:\!BACKUPDATA
set BACKUPLOG=%BACKUPFOLDER%\!LOGS
echo.
pause
goto DRIVEEXIST

:BEGIN
cls
:: SETTING STARTING BACKUP TIME
if %TIME:~0,2% LSS 10 (set Hour=0%TIME:~1,1%) ELSE (set Hour=%TIME:~0,2%)
set TimeStart=%Hour%.%TIME:~3,2%.%TIME:~6,2%
:: SETTING BACKUP LOG FILE LOCATION
set LOGFILE="%BACKUPLOG%\Backup_%date%-[%TimeStart%].log"

:: DISPATCHING TO DIFFERENT DOMAINS
:DISPATCH
REM echo %count%
if %count%==0 set DOMAIN=DOCUMENTS
if %count%==1 set DOMAIN=MUSIQUE
if %count%==2 goto DONE
set OUTPUTDIR="%BACKUPFOLDER%\[%DOMAIN%]"
set /a count=%count%+1
goto :%DOMAIN%

:DOCUMENTS
set INPUTDIR="C:\Users\Xavier\Documents"
goto COPYMIRROR

:MUSIQUE
set INPUTDIR="C:\Users\Xavier\Music"
goto COPYMIRROR

:VIDEOS


:: PURE COPY (ADDING TO BACKUP)
:COPY
Title Backing up %DOMAIN% (%count%/3)
echo. >> %LOGFILE%
echo =================================  %DOMAIN%  ================================== >> %LOGFILE%
echo. >> %LOGFILE%
robocopy %INPUTDIR% %OUTPUTDIR% /E /W:1 /R:100 /ETA /TEE /XJ /XJD /X /V /NJH /LOG+:%LOGFILE%
goto DISPATCH

:: MIRROR COPY (REPLACING CURRENT BACKUP)
:COPYMIRROR
Title Backing up %DOMAIN% (%count%/3)
echo. >> %LOGFILE%
echo =================================  %DOMAIN%  ================================== >> %LOGFILE%
echo. >> %LOGFILE%
robocopy %INPUTDIR% %OUTPUTDIR% /MIR /W:1 /R:100 /ETA /TEE /XJ /XJD /X /V /NJH /LOG+:%LOGFILE%
goto DISPATCH

:: END
:DONE
cls
echo.
Title Backup Done
if %TIME:~0,2% LSS 10 (set Hour=0%TIME:~1,1%) ELSE (set Hour=%TIME:~0,2%)
set TimeEnd=%Hour%.%TIME:~3,2%.%TIME:~6,2%
::TIME ELAPSED
set /a SecondsElapsed=%TimeEnd:~6,2%-%TimeStart:~6,2%
set /a MinutesElapsed=%TimeEnd:~3,2%-%TimeStart:~3,2%
set /a HoursElapsed=%TimeEnd:~0,2%-%TimeStart:~0,2%
if %SecondsElapsed% LSS 0 (
	set /a SecondsElapsed=%SecondsElapsed%+60
	set /a MinutesElapsed=%MinutesElapsed%-1)
if %MinutesElapsed% LSS 0 (
	set /a MinutesElapsed=%MinutesElapsed%+60
	set /a HoursElapsed=%HoursElapsed%-1)
if %HoursElapsed% LSS 0 (set /a HoursElapsed=%HoursElapsed%+24)
echo.
echo ===================================================================================================
echo Started    : %date% %TimeStart%
echo Completed  : %date% %TimeEnd%
echo Elapsed    : %HoursElapsed% hours %MinutesElapsed% minutes %SecondsElapsed% seconds 
echo ===================================================================================================
echo.
echo Log file saved at "%BACKUPLOG%"
echo.
pause 
exit
