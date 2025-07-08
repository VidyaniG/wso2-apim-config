@echo off
echo === Deploying deployment.toml ===

set WSO2_HOME=C:\path\to\wso2am-4.1.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf

echo Stopping running APIM (if any)...
taskkill /F /IM java.exe >nul 2>&1 || echo No java.exe process found to kill

timeout /t 5

echo Backing up old deployment.toml...
copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\deployment.toml.bak" >nul

echo Copying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml" || exit /b 1

echo Starting APIM...
start "WSO2_APIM" "%WSO2_HOME%\bin\api-manager.bat" --start

timeout /t 30

echo Checking if APIM started...
timeout /t 10
