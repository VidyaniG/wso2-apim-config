pipeline {
    agent any
    
    options {
        timeout(time: 15, unit: 'MINUTES')
        retry(2)
    }
    
    environment {
        WSO2_HOME = 'C:\\Users\\DELL\\Downloads\\wso2am-4.1.0 (2)\\wso2am-4.1.0'
        CONFIG_PATH = "${WSO2_HOME}\\repository\\conf"
        BIN_PATH = "${WSO2_HOME}\\bin"
        DEPLOYMENT_FILE = 'deployment.toml'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
                
                // Verify deployment.toml exists
                script {
                    if (!fileExists(DEPLOYMENT_FILE)) {
                        error "deployment.toml file not found in repository"
                    }
                }
            }
        }
        
        stage('Validate Configuration') {
            steps {
                echo 'Validating deployment.toml configuration...'
                script {
                    // Basic validation - check if file is not empty
                    def deploymentContent = readFile(DEPLOYMENT_FILE)
                    if (deploymentContent.trim().isEmpty()) {
                        error "deployment.toml is empty"
                    }
                    
                    // Check for required sections (customize based on your needs)
                    if (!deploymentContent.contains('[server]')) {
                        error "deployment.toml missing [server] section"
                    }
                    
                    echo "Configuration validation passed"
                }
            }
        }
        
        stage('Pre-deployment Check') {
            steps {
                echo 'Checking WSO2 APIM installation...'
                script {
                    // Check if WSO2 APIM directory exists
                    if (!fileExists(WSO2_HOME)) {
                        error "WSO2 APIM installation not found at ${WSO2_HOME}"
                    }
                    
                    // Check if config directory exists
                    if (!fileExists(CONFIG_PATH)) {
                        error "WSO2 APIM config directory not found at ${CONFIG_PATH}"
                    }
                    
                    // Check if api-manager.bat exists
                    if (!fileExists("${BIN_PATH}\\api-manager.bat")) {
                        error "api-manager.bat not found at ${BIN_PATH}"
                    }
                    
                    echo "Pre-deployment checks passed"
                }
            }
        }
        
        stage('Stop Current WSO2 APIM') {
            steps {
                echo 'Stopping current WSO2 APIM instance if running...'
                script {
                    try {
                        // Check if WSO2 APIM process is running
                        def processCheck = bat(
                            script: 'tasklist /FI "IMAGENAME eq java.exe" | find "java.exe"',
                            returnStatus: true
                        )
                        
                        if (processCheck == 0) {
                            echo 'WSO2 APIM process found. Stopping...'
                            
                            // Kill WSO2 APIM related Java processes
                            bat '''
                                for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq java.exe" /FO CSV ^| find "wso2"') do (
                                    echo Stopping WSO2 APIM process %%i
                                    taskkill /PID %%i /F
                                )
                            '''
                            
                            // Wait for process to terminate
                            sleep(time: 10, unit: 'SECONDS')
                            echo 'WSO2 APIM processes stopped'
                        } else {
                            echo 'No WSO2 APIM process found running'
                        }
                    } catch (Exception e) {
                        echo "Error stopping WSO2 APIM: ${e.getMessage()}"
                        echo "Continuing with deployment..."
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying WSO2 APIM configuration...'
                script {
                    try {
                        // Execute deployment script
                        bat """
                            cd /d "${workspace}"
                            call scripts\\deploy.bat
                        """
                        echo 'Deployment completed successfully'
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
        
        stage('Post-deployment Verification') {
            steps {
                echo 'Verifying deployment...'
                script {
                    // Wait for service to start
                    sleep(time: 30, unit: 'SECONDS')
                    
                    // Check if WSO2 APIM process is running
                    def processStatus = bat(
                        script: 'tasklist /FI "IMAGENAME eq java.exe" | find "java.exe"',
                        returnStatus: true
                    )
                    
                    if (processStatus == 0) {
                        echo 'WSO2 APIM process is running'
                        
                        // Wait a bit more for full startup
                        sleep(time: 30, unit: 'SECONDS')
                        
                        // Optional: Check if WSO2 APIM is responding
                        try {
                            def healthCheck = bat(
                                script: 'curl -s --connect-timeout 10 https://localhost:9443/carbon/',
                                returnStatus: true
                            )
                            
                            if (healthCheck == 0) {
                                echo 'WSO2 APIM is responding on port 9443'
                            } else {
                                echo 'WSO2 APIM process is running but may still be starting up'
                            }
                        } catch (Exception e) {
                            echo 'Health check failed (curl might not be available): ' + e.getMessage()
                        }
                    } else {
                        echo 'Warning: WSO2 APIM process not found'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
            // Clean workspace
            cleanWs()
        }
        
        success {
            echo 'Deployment successful!'
            echo 'WSO2 APIM is running in console mode'
            echo 'Access the management console at: https://localhost:9443/carbon/'
        }
        
        failure {
            echo 'Deployment failed!'
            echo 'Check the WSO2 APIM logs for more details'
            echo 'Log location: ${WSO2_HOME}\\repository\\logs'
        }
    }
}
