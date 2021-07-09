
@if not "%MINGW_ROOT%" == "" (@set "PATH=%PATH%;%MINGW_ROOT%")

cd .

if "%1"=="" ("D:\App\MATLAB\R2020b\bin\win64\gmake"  -f demo_02_system_to_be_built.mk all) else ("D:\App\MATLAB\R2020b\bin\win64\gmake"  -f demo_02_system_to_be_built.mk %1)
@if errorlevel 1 goto error_exit

exit 0

:error_exit
echo The make command returned an error of %errorlevel%
exit 1