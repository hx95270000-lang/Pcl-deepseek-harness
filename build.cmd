@echo off
rem 一键构建 PCL + DeepSeek 启动器
setlocal
set "ROOT=%~dp0"
set "SRC=%ROOT%_src\PCL-main"
set "DOTNET_CLI_HOME=%ROOT%.dotnet"
set "NUGET_PACKAGES=%ROOT%.nuget"
set "MSBUILDDISABLENODEREUSE=1"
set "DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1"
set "DOTNET_NOLOGO=1"

set "MSB=C:\Program Files\Microsoft Visual Studio\18\Insiders\MSBuild\Current\Bin\MSBuild.exe"
if not exist "%MSB%" (
  echo [错误] 未找到 MSBuild：%MSB%
  echo 请修改本脚本中的 MSB 变量。
  exit /b 1
)

if not exist "%DOTNET_CLI_HOME%" mkdir "%DOTNET_CLI_HOME%"
if not exist "%NUGET_PACKAGES%" mkdir "%NUGET_PACKAGES%"

echo === 还原 NuGet 包 ===
dotnet restore "%SRC%\PCLCS\PCLCS.csproj" || exit /b 1

echo === 构建 ===
"%MSB%" "%SRC%\Plain Craft Launcher 2\Plain Craft Launcher 2.vbproj" -p:Configuration=Release -m:1 -nodeReuse:false -v:m -nologo || exit /b 1

echo.
echo === 完成 ===
echo 输出：%SRC%\Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe
endlocal
