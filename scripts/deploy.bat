@echo off
echo Starting WSO2 APIM deployment process...

:: Set your WSO2 APIM installation path - UPDATE THIS PATH TO YOUR INSTALLATION
set WSO2_HOME=C:\Users\DELL\Downloads\wso2am-4.1.0 (2)\wso2am-4.1.0
set CONFIG_PATH=%WSO2_HOME%\repository\conf

:: Check if WSO2 APIM is running by looking for the process
echo Checking if WSO2 APIM is running...
tasklist /FI "IMAGENAME eq java.exe" /FO CSV | find /I "java.exe" > nul
if %errorlevel% eq 0 (
    echo WSO2 APIM appears to be running. Please stop it manually before deployment.
    echo Go to your WSO2 APIM console and press Ctrl+C to stop it.
    pause
    echo Press any key after you have stopped WSO2 APIM...
    pause
)

:: Create backup directory if it doesn't exist
if not exist "%CONFIG_PATH%\backups" mkdir "%CONFIG_PATH%\backups"

:: Create timestamp for backup
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"

:: Backup current deployment.toml
echo Creating backup of current deployment.toml...
copy "%CONFIG_PATH%\deployment.toml" "%CONFIG_PATH%\backups\deployment.toml.backup.%timestamp%" > nul
if %errorlevel% neq 0 (
    echo Failed to backup deployment.toml
    exit /b 1
)

:: Copy new deployment.toml from workspace
echo Deploying new deployment.toml...
copy "%WORKSPACE%\deployment.toml" "%CONFIG_PATH%\deployment.toml" > nul
if %errorlevel% neq 0 (
    echo Failed to copy new deployment.toml
    echo Restoring backup...
    copy "%CONFIG_PATH%\backups\deployment.toml.backup.%timestamp%" "%CONFIG_PATH%\deployment.toml" > nul
    exit /b 1
)

echo Deployment completed successfully!
echo.
echo IMPORTANT: You need to manually start WSO2 APIM now.
echo.
echo To start WSO2 APIM:
echo 1. Open Command Prompt
echo 2. Navigate to: %WSO2_HOME%\bin
echo 3. Run: api-manager.bat
echo.
echo Or you can run this command:
echo cd /d "%WSO2_HOME%\bin" && api-manager.bat
echo.
echo The new deployment.toml has been applied.
echo Backup saved as: deployment.toml.backup.%timestamp%
echo.
pause
