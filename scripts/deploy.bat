@echo off
echo Starting WSO2 APIM deployment process...

:: Set your WSO2 APIM installation path - UPDATE THIS PATH TO YOUR INSTALLATION
set WSO2_HOME=C:\Users\DELL\Downloads\wso2am-4.1.0 (2)\wso2am-4.1.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf

:: Check if WSO2 APIM is running by looking for the process (fixed syntax)
echo Checking if WSO2 APIM is running...
tasklist /FI "IMAGENAME eq java.exe" /FO CSV | find /I "java.exe" >nul 2>&1
if not errorlevel 1 (
    echo WSO2 APIM appears to be running. Please stop it manually before deployment.
    echo Go to your WSO2 APIM console and press Ctrl+C to stop it.
    echo.
    echo IMPORTANT: This script will continue in 10 seconds...
    echo Press Ctrl+C now if you need to stop WSO2 APIM first.
    timeout /t 10 /nobreak >nul
)

:: Check if WSO2_HOME directory exists
if not exist "%WSO2_HOME%" (
    echo ERROR: WSO2 APIM installation not found at %WSO2_HOME%
    echo Please update the WSO2_HOME path in this script.
    exit /b 1
)

:: Check if CONFIG_PATH exists
if not exist "%CONFIG_PATH%" (
    echo ERROR: Config directory not found at %CONFIG_PATH%
    exit /b 1
)

:: Create backup directory if it doesn't exist
if not exist "%CONFIG_PATH%\backups" mkdir "%CONFIG_PATH%\backups"

:: Create timestamp for backup
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"

:: Check if original deployment.toml exists
if not exist "%CONFIG_PATH%\deployment.toml" (
    echo ERROR: Original deployment.toml not found at %CONFIG_PATH%\deployment.toml
    exit /b 1
)

:: Backup current deployment.toml
echo Creating backup of current deployment.toml...
copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\backups\deployment.toml.backup.%timestamp%" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to backup deployment.toml
    exit /b 1
)

:: Check if new deployment.toml exists in workspace
if not exist "%WORKSPACE%\deployment.toml" (
    echo ERROR: New deployment.toml not found in workspace: %WORKSPACE%\deployment.toml
    exit /b 1
)

:: Copy new deployment.toml from workspace
echo Deploying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy new deployment.toml
    echo Restoring backup...
    copy "%CONFIG_PATH%\backups\deployment.toml.backup.%timestamp%" "%CONFIG_PATH%\deployment.toml" >nul
    exit /b 1
)

echo.
echo ========================================
echo ✅ Deployment completed successfully!
echo ========================================
echo.
echo Configuration Details:
echo - WSO2 APIM Home: %WSO2_HOME%
echo - Config Path: %CONFIG_PATH%
echo - Backup Created: deployment.toml.backup.%timestamp%
echo - Workspace: %WORKSPACE%
echo.
echo NEXT STEPS:
echo 1. Open Command Prompt as Administrator
echo 2. Navigate to: %WSO2_HOME%\bin
echo 3. Run: api-manager.bat
echo 4. Wait for startup to complete
echo 5. Access WSO2 APIM at: https://localhost:9443/carbon
echo.
echo Quick Start Command:
echo cd /d "%WSO2_HOME%\bin" ^&^& api-manager.bat
echo.
echo ========================================
