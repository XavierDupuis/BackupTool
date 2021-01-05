::: BACKUP TOOL USED TO SYNC USEFUL DATA TO EXTERNAL HARD DRIVE

:: USER INTERFACE
echo off
mode con:cols=100 lines=20
Title Backup

:: READING CUSTOM USER INPUTS
set DEFAULT_DESTINATION_DRIVE=F
set DEFAULT_SOURCE_DIRECTORY=%userprofile%
if exist "profile" (
	cd profile
    set /p DESTINATION_DRIVE=<DESTINATION_DRIVE.txt
    set /p SOURCE_DIRECTORY=<SOURCE_DIRECTORY.txt
    cd ..
    ) ELSE (
    set /p DESTINATION_DRIVE=%DEFAULT_DESTINATION_DRIVE%
    set /p SOURCE_DIRECTORY=%DEFAULT_SOURCE_DIRECTORY%
)
if [%DESTINATION_DRIVE%]==[] (
    set DESTINATION_DRIVE=%DEFAULT_DESTINATION_DRIVE%
)
if [%SOURCE_DIRECTORY%]==[] (
    set SOURCE_DIRECTORY=%DEFAULT_SOURCE_DIRECTORY%
)

:: HEADER
echo.
echo ===================================================================================================
echo =============              Proceed for Backup? (Backup Drive set to %DESTINATION_DRIVE%:\)              =============
echo ===================================================================================================
echo.
Pause

:: SETTING COUNT OF DOMAINS
set count=0

:: SETTING BACKUP LOCATION AND LOG FOLDER LOCATION
set BACKUPFOLDER=%DESTINATION_DRIVE%:\!BACKUPDATA
set BACKUPLOG=%BACKUPFOLDER%\!LOGS
REM set BACKUPFOLDER=%cd%
REM set BACKUPLOG=%cd%

:: CONFIRM BACKUP LOCATION && PROMPT RETRYING
:DRIVEEXIST
if exist "%BACKUPFOLDER%" (
	if NOT exist "%BACKUPLOG%" (
		mkdir %BACKUPLOG%
	)
	goto BEGIN) ELSE (
	cls
	echo.
	echo No Backup location was found
	echo %BACKUPFOLDER:~0,3% drive not available
	echo.
	goto NEWDRIVE)
:NEWDRIVE
echo [Enter new drive letter]
set /p DESTINATION_DRIVE=
set BACKUPFOLDER=%DESTINATION_DRIVE%:\!BACKUPDATA
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
set total=6
if %count%==0 set DOMAIN=DOCUMENTS
if %count%==1 set DOMAIN=DESKTOP
if %count%==2 set DOMAIN=ONEDRIVE
if %count%==3 set DOMAIN=MUSIC
if %count%==4 set DOMAIN=VIDEOS
if %count%==5 set DOMAIN=PICTURES
if %count%==%total% goto DONE
set INPUTDIR="%SOURCE_DIRECTORY%\%DOMAIN%"
set OUTPUTDIR="%BACKUPFOLDER%\[%DOMAIN%]"
set /a count=%count%+1
goto :%DOMAIN%

:DOCUMENTS
goto COPYMIRROR

:DESKTOP
goto COPY

:MUSIC
goto COPYMIRROR

:ONEDRIVE
cd /d %LOCALAPPDATA%\Microsoft\OneDrive
OneDrive.exe /shutdown
timeout 3
cd /d %SOURCE_DIRECTORY%
goto COPYMIRROR

:VIDEOS
goto COPYMIRROR

:PICTURES
goto COPYMIRROR

:: PURE COPY (ADDING TO BACKUP)
:COPY
Title Backing up %DOMAIN% (%count%/%total%)
echo. >> %LOGFILE%
echo =================================  %DOMAIN%  ================================== >> %LOGFILE%
echo. >> %LOGFILE%
robocopy %INPUTDIR% %OUTPUTDIR% /E /W:0 /R:10 /ETA /TEE /XJ /XJD /X /V /NJH /LOG+:%LOGFILE%
goto DISPATCH

:: MIRROR COPY (REPLACING CURRENT BACKUP)
:COPYMIRROR
Title Backing up %DOMAIN% (%count%/%total%)
echo. >> %LOGFILE%
echo =================================  %DOMAIN%  ================================== >> %LOGFILE%
echo. >> %LOGFILE%
robocopy %INPUTDIR% %OUTPUTDIR% /MIR /W:0 /R:10 /ETA /TEE /XJ /XJD /X /V /NJH /LOG+:%LOGFILE%
goto DISPATCH

:: END
:DONE
cls
echo.
Title Backup Done

echo.
echo ===================================================================================================
echo =============                             BACKUP COMPLETED                            =============
echo ===================================================================================================
echo.

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
echo. >> %LOGFILE%
echo =================================================================================================== >> %LOGFILE%
echo Started    : %date% %TimeStart% >> %LOGFILE%
echo Completed  : %date% %TimeEnd% >> %LOGFILE%
echo Elapsed    : %HoursElapsed% hours %MinutesElapsed% minutes %SecondsElapsed% seconds  >> %LOGFILE%
echo =================================================================================================== >> %LOGFILE%
cd /d %BACKUPLOG%
del latest.log
copy %LOGFILE% latest.log
echo ===================================================================================================
echo Started    : %date% %TimeStart%
echo Completed  : %date% %TimeEnd%
echo Elapsed    : %HoursElapsed% hours %MinutesElapsed% minutes %SecondsElapsed% seconds 
echo ===================================================================================================
echo.
echo Log file saved at "%BACKUPLOG%" (latest.log)
echo.

::(RESTARTING ONEDRIVE SYNC SERVICE)
cd /d %LOCALAPPDATA%\Microsoft\OneDrive
start Onedrive.exe
cd /d %USERPROFILE%

pause
exit