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
                    for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv ^| findstr /i "org.wso2.carbon.bootstrap.Bootstrap"') do taskkill /PID %%a /F
                    ping 127.0.0.1 -n 6 > nul
                    start "" "%APIM_HOME%\\bin\\api-manager.bat"
                """
            }
        }
        stage('Check WSO2 Status') {
                steps {
                    bat '''
                        powershell -Command "try {
                            $response = Invoke-WebRequest -Uri http://localhost:9443/publisher -UseBasicParsing -TimeoutSec 30
                            if ($response.StatusCode -eq 200) {
                                Write-Host 'WSO2 APIM is up'
                                exit 0
                            } else {
                                Write-Host 'WSO2 APIM returned unexpected status'
                                exit 1
                            }
                        } catch {
                            Write-Host 'Failed to connect to WSO2 APIM'
                            exit 1
                        }"
                    '''
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
