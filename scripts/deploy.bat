@echo off
echo Starting WSO2 APIM deployment process (Console Mode)...

:: Set your WSO2 APIM installation path
set WSO2_HOME=C:\Users\DELL\Downloads\wso2am-4.1.0 (2)\wso2am-4.1.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf
set BIN_PATH=%WSO2_HOME%\bin

:: Check if WSO2 APIM is currently running
echo Checking if WSO2 APIM is running...
tasklist /FI "IMAGENAME eq java.exe" | find "java.exe" > nul
if %errorlevel% eq 0 (
    echo WSO2 APIM appears to be running. Attempting to stop...
    
    :: Kill WSO2 APIM process (more forceful approach)
    for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq java.exe" /FO CSV ^| find "wso2"') do (
        echo Stopping WSO2 APIM process %%i
        taskkill /PID %%i /F
    )
    
    :: Alternative: Kill all java processes (use with caution)
    :: taskkill /F /IM java.exe
    
    echo Waiting for process to fully terminate...
    timeout /t 10 /nobreak
) else (
    echo WSO2 APIM is not currently running
)

:: Backup current deployment.toml
echo Creating backup of current deployment.toml...
if exist "%CONFIG_PATH%\deployment.toml" (
    copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\deployment.toml.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" > nul
    if %errorlevel% neq 0 (
        echo Failed to backup deployment.toml
        exit /b 1
    )
    echo Backup created successfully
) else (
    echo No existing deployment.toml found - this might be the first deployment
)

:: Copy new deployment.toml
echo Deploying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml" > nul
if %errorlevel% neq 0 (
    echo Failed to copy new deployment.toml
    exit /b 1
)
echo New deployment.toml deployed successfully

:: Start WSO2 APIM in background
echo Starting WSO2 APIM in console mode...
cd /d "%BIN_PATH%"

:: Start WSO2 APIM in background using START command
start "WSO2 APIM" /MIN api-manager.bat
if %errorlevel% neq 0 (
    echo Failed to start WSO2 APIM
    echo Restoring backup...
    if exist "%CONFIG_PATH%\deployment.toml.backup.*" (
        copy "%CONFIG_PATH%\deployment.toml.backup.*" "%CONFIG_PATH%\deployment.toml" > nul
    )
    exit /b 1
)

echo WSO2 APIM started in console mode (minimized window)
echo Waiting for WSO2 APIM to fully start...
timeout /t 45 /nobreak

:: Check if WSO2 APIM process is running
tasklist /FI "IMAGENAME eq java.exe" | find "java.exe" > nul
if %errorlevel% eq 0 (
    echo WSO2 APIM process is running
    
    :: Optional: Check if WSO2 APIM is responding (requires curl)
    echo Checking if WSO2 APIM is responding...
    curl -s --connect-timeout 10 https://localhost:9443/carbon/ > nul 2>&1
    if %errorlevel% eq 0 (
        echo WSO2 APIM is responding on port 9443
    ) else (
        echo WSO2 APIM process is running but may still be starting up
    )
) else (
    echo Warning: WSO2 APIM process not found
)

echo Deployment process completed!
echo.
echo Note: WSO2 APIM is running in console mode in a minimized window
echo To stop WSO2 APIM, you can either:
echo 1. Close the console window manually
echo 2. Use taskkill /F /IM java.exe (kills all Java processes)
echo 3. Use Ctrl+C in the WSO2 APIM console window
