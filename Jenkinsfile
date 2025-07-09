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
        stage('Restart WSO2 APIM') {
            steps {
                bat """
                    "C:\\Users\\DELL\\Downloads\\nssm-2.24-101-g897c7ad\\nssm-2.24-101-g897c7ad\\win32\\nssm.exe" stop wso2-apim
                    timeout /t 10 /nobreak
                    "C:\\Users\\DELL\\Downloads\\nssm-2.24-101-g897c7ad\\nssm-2.24-101-g897c7ad\\win32\\nssm.exe" start wso2-apim
                """
            }
        }
        stage('Verify Startup') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            script {
                                def result = bat(
                                    script: 'curl -f -k https://localhost:9443/carbon/admin/login.jsp',
                                    returnStatus: true
                                )
                                return result == 0
                            }
                        }
                    }
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
