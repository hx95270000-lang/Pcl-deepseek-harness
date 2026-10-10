@echo off
rem 仅用于在本机沙箱环境下验证：把临时与漫游目录都指向工作区
set "TEMP=C:\Users\1\Downloads\dsh pcl\.tmp"
set "TMP=C:\Users\1\Downloads\dsh pcl\.tmp"
set "APPDATA=C:\Users\1\Downloads\dsh pcl\.appdata\Roaming"
set "LOCALAPPDATA=C:\Users\1\Downloads\dsh pcl\.appdata\Local"
if not exist "C:\Users\1\Downloads\dsh pcl\.tmp" mkdir "C:\Users\1\Downloads\dsh pcl\.tmp"
if not exist "C:\Users\1\Downloads\dsh pcl\.appdata\Roaming" mkdir "C:\Users\1\Downloads\dsh pcl\.appdata\Roaming"
if not exist "C:\Users\1\Downloads\dsh pcl\.appdata\Local" mkdir "C:\Users\1\Downloads\dsh pcl\.appdata\Local"
cd /d "%~dp0"
start "PCL" "C:\Users\1\Downloads\dsh pcl\_src\PCL-main\Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe"
exit /b 0
