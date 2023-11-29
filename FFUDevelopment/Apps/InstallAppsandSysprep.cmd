REM Check if we've already set our progress breadcrumbs.
REM These files are used to determine which part of the script we were last in before rebooting.
REM This script will reboot the VM twice.
REM   1. Once to allow the pending app install actions to complete and begin installing Windows updates
REM   2. A second time to complete the Windows Update insatllation and cleanup the Windows image
IF NOT EXIST "%WINDIR%\FFULOG" (
    MKDIR "%WINDIR%\FFULOG"
)
IF EXIST "%WINDIR%\FFULOG\UpdatesComplete.DAT" GOTO UPDATES_COMPLETE
IF EXIST "%WINDIR%\FFULOG\AppInstallComplete.DAT" GOTO APPS_COMPLETE
REM -------------------------------------------------------------------------

REM Put each app install on a separate line
REM M365 Apps/Office ProPlus
%~dp0Office\setup.exe /configure d:\Office\DeployFFU.xml
REM Add additional apps below here
REM Contoso App (Example)
REM msiexec /i d:\Contoso\setup.msi /qn /norestart

:MSI_INSTALLERS
REM -------------------------------------------------------------------------
REM Call the script to process MSI application installs
CALL %~dp0MSI_Installers\install.cmd
REM Set the Breadcrumb for "Applicaiton Installs Completed"
ECHO %DATE% %TIME% > %WINDIR%\FFULOG\AppInstallComplete.DAT 
REM End of Apps Section. Restart Computer
REM Call for restart with reason code "Application: Installation (Planned)"
SHUTDOWN /F /R /T 0 /D P:4:2

:APPS_COMPLETE
REM -------------------------------------------------------------------------
REM Call the script to process updates
CALL %~dp0WindowsUpdates\update.cmd
ECHO %DATE% %TIME% > %WINDIR%\FFULOG\UpdatesComplete.DAT 
REM Call for restart with reason code "Operating System: Hot fix (Planned)"
ShUTDOWN /R /T 0 /D P:2:17

:UPDATES_COMPLETE
REM -------------------------------------------------------------------------
CALL %~dp0Windows_Updates\after_update.cmd
REM The below lines will remove the unattend.xml that gets the machine into audit mode. If not removed, the OS will get stuck booting to audit mode each time.
REM Also kills the sysprep process in order to automate sysprep generalize
del c:\windows\panther\unattend\unattend.xml /F /Q
del c:\windows\panther\unattend.xml /F /Q
taskkill /IM sysprep.exe
timeout /t 10
c:\windows\system32\sysprep\sysprep.exe /quiet /generalize /oobe
s