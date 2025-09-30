pipeline {
    agent any

    environment {
        // Define NSSM path as an environment variable for clarity
        NSSM_PATH = "D:\\C_DRIVE\\Downloads\\nssm-2.24-101-g897c7ad\\nssm-2.24-101-g897c7ad\\win64\\nssm.exe"
        SERVICE_NAME = "wso2-apim" // The name of your WSO2 APIM NSSM service
        APIM_HOME = "D:\\C_DRIVE\\Downloads\\wso2am-4.1.0_new\\wso2am-4.1.0"
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

        stage('Restart WSO2 APIM Service') {
            steps {
                script {
                    echo "Attempting to stop WSO2 APIM service: ${env.SERVICE_NAME}"
                    // 1. Stop the service using NSSM. This command blocks until the service has stopped or timed out.
                    bat "\"${env.NSSM_PATH}\" stop ${env.SERVICE_NAME}"
                    echo "Service stop command executed. Waiting for a moment before starting..."
                    
                    // Add a brief, yet safe, delay after stop to ensure the port is released
                    bat 'timeout /t 10 /nobreak'
                    
                    echo "Attempting to start WSO2 APIM service: ${env.SERVICE_NAME}"
                    // 2. Start the service using NSSM. This command is usually non-blocking.
                    bat "\"${env.NSSM_PATH}\" start ${env.SERVICE_NAME}"
                    echo "Service start command executed."
                }
            }
        }
        
        stage('Verify Startup') {
            steps {
                script {
                    echo "Waiting for WSO2 APIM to be fully up and running..."
                    // Increase the timeout to 10 minutes to accommodate long startup times (up to 45 min mentioned)
                    timeout(time: 10, unit: 'MINUTES') { 
                        waitUntil {
                            script {
                                // Use curl to check for a successful HTTP status (returnStatus 0)
                                def result = bat(
                                    script: 'curl -f -k https://localhost:9443/carbon/admin/login.jsp',
                                    returnStatus: true
                                )
                                // Log the status check attempts
                                if (result != 0) {
                                    echo "Startup verification failed (status ${result}). Retrying..."
                                }
                                return result == 0
                            }
                        }
                    }
                    echo 'WSO2 APIM is fully started and reachable.'
                }
            }
        }
    }

    post {
        success {
            echo 'WSO2 APIM restarted successfully with new deployment.toml'
        }
        failure {
            echo 'Deployment failed. Check Jenkins and WSO2 APIM logs for errors.'
        }
    }
}
