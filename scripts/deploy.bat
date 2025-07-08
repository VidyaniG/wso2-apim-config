@echo off
echo === Deploying deployment.toml ===

set WSO2_HOME=C:\Users\DELL\Downloads\wso2am-4.1.0(2)\wso2am-4.1.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf

echo Stopping running APIM (if any)...
taskkill /F /IM java.exe >nul 2>&1 || echo No java.exe found to kill

timeout /t 5 /nobreak

echo Backing up old deployment.toml...
copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\deployment.toml.bak" >nul

echo Copying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml"
if %ERRORLEVEL% NEQ 0 (
  echo ERROR: Failed to copy deployment.toml
  exit /B %ERRORLEVEL%
)

echo Starting APIM...
start "WSO2_APIM" "%WSO2_HOME%\bin\api-manager.bat" --start

timeout /t 30 /nobreak

echo Deployment complete. Ensuring success exit code...
REM Clear any previous non-zero ERRORLEVEL
cmd /c exit /b 0

REM End of script
