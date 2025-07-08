pipeline {
    agent any
    
    options {
        timeout(time: 10, unit: 'MINUTES')
        retry(2)
    }
    
    environment {
        // UPDATE THIS PATH TO YOUR WSO2 APIM INSTALLATION
        WSO2_HOME = 'C:\\Users\\DELL\\Downloads\\wso2am-4.1.0 (2)\\wso2am-4.1.0'
        CONFIG_PATH = "${WSO2_HOME}\\repository\\conf"
        DEPLOYMENT_FILE = 'deployment.toml'
        SERVER_IP = '192.168.56.1' // Your local PC IP - update this
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
                    echo "Found deployment.toml file"
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
                    echo "Deploying to server IP: ${SERVER_IP}"
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
                    def apiManagerBat = "${WSO2_HOME}\\bin\\api-manager.bat"
                    if (!fileExists(apiManagerBat)) {
                        error "api-manager.bat not found at ${apiManagerBat}"
                    }
                    
                    echo "Pre-deployment checks passed"
                }
            }
        }
        
        stage('Deploy Configuration') {
            steps {
                echo 'Deploying WSO2 APIM configuration...'
                script {
                    try {
                        // Execute deployment script
                        bat """
                            cd /d "${workspace}"
                            call scripts\\deploy.bat
                        """
                        echo 'Configuration deployment completed successfully'
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
        
        stage('Post-deployment Instructions') {
            steps {
                echo 'Deployment completed! Manual action required:'
                echo '========================================='
                echo '1. Open Command Prompt'
                echo "2. Navigate to: ${WSO2_HOME}\\bin"
                echo '3. Run: api-manager.bat'
                echo '4. Wait for WSO2 APIM to start completely'
                echo '5. Access WSO2 APIM at: https://localhost:9443/carbon'
                echo '========================================='
                
                script {
                    echo "Server IP: ${SERVER_IP}"
                    echo "Alternative access URL: https://${SERVER_IP}:9443/carbon"
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
            echo '✅ Deployment successful!'
            echo 'New deployment.toml has been applied to WSO2 APIM'
            echo 'Please manually start WSO2 APIM using api-manager.bat'
        }
        
        failure {
            echo '❌ Deployment failed!'
            echo 'Check the logs above for error details'
            echo 'Original deployment.toml has been restored from backup'
        }
    }
}
