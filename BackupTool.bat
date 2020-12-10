@mode con:cols=70 lines=12
@Title Backup

@echo Proceed for Backup?
@Pause

@set TimeStart=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%
@echo Started : %date% %TimeStart%

@set BACKUPLOG=F:\BackupData
@MKDIR %BACKUPLOG%\Backup_%date%-[%TimeStart%]
@set BACKUPLOG=%BACKUPLOG%\Backup_%date%-[%TimeStart%]

:Music
@set DOMAIN=Music
@set INPUTDIR="C:\Users\Xavier\Music\iTunes\iTunes Media\Music"
@set OUTPUTDIR="F:\Musique\iTunes\iTunes Media\Music"
@set INPUTDIR="C:\Users\Xavier\Desktop\1"
@set OUTPUTDIR="C:\Users\Xavier\Desktop\2"

:COPY
@Title Backing up %INPUTDIR%
@robocopy %INPUTDIR% %OUTPUTDIR% /MIR /XA:SH /W:1 /R:100 /ETA /XJ > "%BACKUPLOG%\Backup_%date%-[%TimeStart%]-%DOMAIN%.log"

@cls
@echo.
@Title Backup Done
@echo.
@set TimeEnd=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%
@echo Started   : %date% %TimeStart%
@echo Completed : %date% %TimeEnd%
@echo.
@echo Log folder saved at "%BACKUPLOG%"
@echo.
@pause
@exit
