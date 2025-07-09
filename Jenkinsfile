pipeline {
    agent any

    environment {
        APIM_HOME = "C:\\Users\\DELL\\Downloads\\wso2am-4.1.0(2)\\wso2am-4.1.0"
        DEPLOYMENT_FILE_PATH = "${APIM_HOME}\\repository\\conf\\deployment.toml"
        SERVER_IP = "192.168.56.1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/VidyaniG/wso2-apim-config.git'
            }
        }

        stage('Replace deployment.toml') {
            steps {
                bat """
                    copy /Y deployment.toml "%DEPLOYMENT_FILE_PATH%"
                """
            }
        }

        stage('Stop WSO2 APIM') {
            steps {
                script {
                    bat """
                        echo Stopping WSO2 APIM...
                        wmic process where "CommandLine like '%%org.wso2.carbon.bootstrap.Bootstrap%%'" delete
                        ping 127.0.0.1 -n 16 > nul
                        echo Process stopped successfully
                    """
                }
            }
        }
        stage('Start WSO2 APIM') {
            steps {
                bat """
                    echo Starting WSO2 APIM...
                    cd /d "%APIM_HOME%\\bin"
                    start "WSO2 APIM" /MIN api-manager.bat
                    ping 127.0.0.1 -n 31 > nul
                    echo WSO2 APIM startup initiated
                """
            }
        }
        stage('Verify Startup') {
            steps {
                script {
                    bat """
                        echo Verifying WSO2 APIM startup...
                        ping 127.0.0.1 -n 11 > nul
                        
                        REM Check if process is running
                        wmic process where "CommandLine like '%%org.wso2.carbon.bootstrap.Bootstrap%%'" get ProcessId /value | find "ProcessId=" > nul
                        if errorlevel 1 (
                            echo ERROR: WSO2 APIM process not found
                            exit /b 1
                        ) else (
                            echo WSO2 APIM process is running
                        )
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'WSO2 APIM restarted with new deployment.toml'
        }
        failure {
            echo 'Deployment failed. Check logs.'
        }
    }
}
