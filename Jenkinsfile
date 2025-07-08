pipeline {
    agent any

    environment {
        APIM_HOME = "C:\\Users\\DELL\\Downloads\\wso2am-4.1.0(2)\\wso2am-4.1.0"
        DEPLOYMENT_FILE_PATH = "${APIM_HOME}\\repository\\conf\\deployment.toml"
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

        stage('Restart WSO2 APIM') {
            steps {
                bat """
                    taskkill /F /IM java.exe || echo "No WSO2 process running"
                    ping 127.0.0.1 -n 6 > nul
                    start "" "%APIM_HOME%\\bin\\api-manager.bat"
                """
            }
        }
        stage('Check WSO2 Status') {
            steps {
                bat """
                    powershell -Command "try { Invoke-WebRequest -Uri http://localhost:9443/publisher -UseBasicParsing -TimeoutSec 30 } catch { exit 1 }"
                """
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
