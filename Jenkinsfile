pipeline {
    agent any

    environment {
        APIM_HOME = "D:\\C_DRIVE\\Downloads\\wso2am-4.1.0_new\\wso2am-4.1.0"
        DEPLOYMENT_FILE_PATH = "${APIM_HOME}\\repository\\conf\\deployment.toml"
        SERVER_IP = "192.168.56.1"
        NSSM_EXE = "D:\\C_DRIVE\\Downloads\\nssm-2.24-101-g897c7ad\\nssm-2.24-101-g897c7ad\\win64\\nssm.exe"
        LOG_FILE = "${APIM_HOME}\\repository\\logs\\wso2carbon.log"
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
                        "%NSSM_EXE%" stop wso2-apim
                        ping 127.0.0.1 -n 20 > nul
                        echo Process stopped successfully
                    """
                }
            }
        }
        stage('Restart WSO2 APIM') {
            steps {
                bat """
                    echo Starting WSO2 APIM...
                    "%NSSM_EXE%" start wso2-apim
                """
            }
        }
        stage('Verify Startup') {
            steps {
                script {
                    timeout(time: 7, unit: 'MINUTES') {
                        retry(30) {
                            sleep(time: 10, unit: 'SECONDS')

                            // Check if log contains "Mgt Console URL"
                            def logCheck = bat(
                                script: "findstr /C:\"Mgt Console URL\" \"%LOG_FILE%\"",
                                returnStatus: true
                            )

                            if (logCheck != 0) {
                                error "APIM not ready yet, retrying..."
                            }

                            // Final curl check
                            def result = bat(
                                script: "curl -f -k https://localhost:9443/carbon/admin/login.jsp",
                                returnStatus: true
                            )
                            if (result != 0) {
                                error "Carbon console not reachable yet, retrying..."
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
