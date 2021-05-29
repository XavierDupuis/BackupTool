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
		echo Error : %BACKUPFOLDER:~0,3% drive not available
		echo 	Connect "%BACKUPFOLDER:~0,3%" drive or create "%BACKUPFOLDER:~0,3%!BACKUPDATA" folder
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
set "TimeStart=%time: =0%"
set "TimeStart=%TimeStart::=.%"
set "TimeStart=%TimeStart:~0,8%"

:: SETTING BACKUP LOG FILE LOCATION
set LOGFILE="%BACKUPLOG%\Backup_%date%-[%TimeStart%].log"

:: DISPATCHING TO DIFFERENT DOMAINS
set count=0
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
goto COPY

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

set "TimeEnd=%time: =0%"
set "TimeEnd=%TimeEnd::=.%"
set "TimeEnd=%TimeEnd:~0,8%"

::TIME ELAPSED
if %TimeStart:~6,1% == 0 (set SecondsStart=%TimeStart:~7,1%) else (set SecondsStart=%TimeStart:~6,2%)
if %TimeEnd:~6,1% == 0   (set SecondsEnd=%TimeEnd:~7,1%)     else (set SecondsEnd=%TimeEnd:~6,2%)
set /a SecondsElapsed=SecondsEnd-SecondsStart
if %TimeStart:~3,1% == 0 (set MinutesStart=%TimeStart:~4,1%) else (set MinutesStart=%TimeStart:~3,2%)
if %TimeEnd:~3,1% == 0   (set MinutesEnd=%TimeEnd:~4,1%)     else (set MinutesEnd=%TimeEnd:~3,2%)
set /a MinutesElapsed=MinutesEnd-MinutesStart
if %TimeStart:~0,1% == 0 (set HoursStart=%TimeStart:~1,1%) else (set HoursStart=%TimeStart:~0,2%)
if %TimeEnd:~0,1% == 0   (set HoursEnd=%TimeEnd:~1,1%)     else (set HoursEnd=%TimeEnd:~0,2%)
set /a HoursElapsed=HoursEnd-HoursStart
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
echo Elapsed    : %HoursElapsed% hour(s) %MinutesElapsed% minute(s) %SecondsElapsed% second(s)  >> %LOGFILE%
echo =================================================================================================== >> %LOGFILE%
cd /d %BACKUPLOG%
del latest.log
copy %LOGFILE% latest.log
echo ===================================================================================================
echo Started    : %date% %TimeStart%
echo Completed  : %date% %TimeEnd%
echo Elapsed    : %HoursElapsed% hour(s) %MinutesElapsed% minute(s) %SecondsElapsed% second(s) 
echo ===================================================================================================
echo.
echo Log file saved at "%BACKUPLOG%" (latest.log)
echo.

::RESTARTING ONEDRIVE SYNC SERVICE
cd /d %LOCALAPPDATA%\Microsoft\OneDrive
start Onedrive.exe
cd /d %USERPROFILE%

pause
exit

:remove_leading_zeros
SET /a %1 = 1%1-(11%1-1%1)/10
EXIT /B
