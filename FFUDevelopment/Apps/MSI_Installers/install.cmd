@ECHO OFF
SETLOCAL EnableDelayedExpansion
PUSHD %~dp0
FOR /F "tokens=* usebackq" %%A IN (`DIR /S /B *.msi`) DO (
    REM Check for MST files
    SET TRANSFORMS=NONE
    REM Each installer will create a log file in: C:\Windows\FFULOG\InstallApp_AppName.LOG
    SET INSTALLLOG="%WINDIR%\FFULOG\InstallApp_%%~n.LOG"
    REM Check if we are dealing with MSi transforms and handle them cleanly.
    DIR /A %%~dpA\*.MST >NUL 2>NUL
    IF NOT ERRORLVEL 1 (
        FOr /F "tokens=* usebackq" %%T IN ('DIR /B "%%~dpA\*.MST"`) DO (
            CALL :BUILD_TRANSFORMS TRANSFORMS !TRANSFORMS! "%%~fT"
        )
        REM Transform file found and required for this MSI file. Use transform options
        MSIEXEC /I "%%~fA" /l*v !INSTALLLOG! /qn /norestart ALLUSERS=2 REBOOT=ReallySuppress TRANFORMS=!TRANSFORMS!
    ) ELSE (
        REM No transforms required for this MSI file. Use default options
        MSIEXEC /I "%%~fA" /l*v !INSTALLLOG! /qn /norestart ALLUSERS=2 REBOOT=ReallySuppress
        SET ERRLVL=!ERRORLEVEL!
        IF %ERRLVL% GEQ 1 (
            REM Check for special case 3010 (installed successfully but reboot required)
            IF %ERRLVL% = 3010 (
                REM Reboot is required  but we'll do this after all installers have completed
                ECHO SUCCESS:  Installed %%~n.msi ^(with reboot required^)
            ) ELSE (
                REM An actual error occured while running the installer
                ECHO ERROR: Failed to install %%~n.msi with error code %ERRLVL%
                ECHO ERROR: Failed to install %%~n.msi with error code %ERRLVL% >> 
            )
        ) ELSE (
            ECHO SUCCESS:  Installed %%~n.msi 
        )
    )
)
POPD
ENDLOCAL
GOTO :EOF

REM Call this function to build out the transforms list.
REM   Parameter 1: Variable name to update (TRANFORMS)
REM   Parameter 2: Current value (%TRANSFORMS%)
REM   Parameter 3: Value to be appended
:BUILD_TRANSFORMS
    ECHO %2 | FIND /I "MST" >NUL 2>NUL
    IF ERRORLEVEL 1 (
        REM MST was not found, must be the first time here.
        SET %1="%~f3"
    ) ELSE (
        REM We already have an MST, append
        SET %1=%2;"%~f3"
    )
    
    GOTO :EOF

:END