@ECHO OFF

PUSHD %~DP0
FOR /F "tokens=* usebackq" %%A IN (`DIR /A/S/B *.msu`) DO (
    ECHO Processing Update: %%~nA
    %SYSTEMROOT%\SYSTEM32\DISM.EXE /Online /Add-package /PackagePath:"%%~fA" 
)

POPD