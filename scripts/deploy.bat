@echo off
echo Starting WSO2 APIM deployment process...

:: Set your WSO2 APIM installation path
set WSO2_HOME=C:\wso2am-4.2.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf

:: Stop WSO2 APIM service
echo Stopping WSO2 APIM service...
net stop "WSO2 API Manager"
if %errorlevel% neq 0 (
    echo Failed to stop WSO2 APIM service
    exit /b 1
)

:: Wait for service to fully stop
timeout /t 10 /nobreak

:: Backup current deployment.toml
echo Creating backup of current deployment.toml...
copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\deployment.toml.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" > nul
if %errorlevel% neq 0 (
    echo Failed to backup deployment.toml
    exit /b 1
)

:: Copy new deployment.toml
echo Deploying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml" > nul
if %errorlevel% neq 0 (
    echo Failed to copy new deployment.toml
    exit /b 1
)

:: Start WSO2 APIM service
echo Starting WSO2 APIM service...
net start "WSO2 API Manager"
if %errorlevel% neq 0 (
    echo Failed to start WSO2 APIM service
    echo Restoring backup...
    copy "%CONFIG_PATH%\deployment.toml.backup.*" "%CONFIG_PATH%\deployment.toml" > nul
    net start "WSO2 API Manager"
    exit /b 1
)

echo Deployment completed successfully!
echo Waiting for service to fully start...
timeout /t 30 /nobreak

:: Optional: Check if service is running
sc query "WSO2 API Manager" | find "RUNNING" > nul
if %errorlevel% eq 0 (
    echo WSO2 APIM service is running successfully
) else (
    echo Warning: WSO2 APIM service status unclear
)

echo Deployment process completed!
