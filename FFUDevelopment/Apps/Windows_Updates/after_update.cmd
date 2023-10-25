@ECHO OFF
REM Use DISM to cleanup the WinSxS store (updates bloat this) and reset the base image to 
REM the version applied by the applied Windows updates
%SYSTEMROOT%\SYSTEM32\DISM.EXE /Online /Cleanup-Image /StartComponentCleanup /ResetBase