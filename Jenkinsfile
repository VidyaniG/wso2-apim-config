pipeline {
    agent any
    
    options {
        timeout(time: 10, unit: 'MINUTES')
        retry(2)
    }
    
    environment {
        WSO2_HOME = 'C:\\Users\\DELL\\Downloads\\wso2am-4.1.0 (2)\\wso2am-4.1.0'
        CONFIG_PATH = "${WSO2_HOME}\\repository\\conf"
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
                echo 'Checking WSO2 APIM service status...'
                script {
                    // Check if WSO2 APIM directory exists
                    if (!fileExists(WSO2_HOME)) {
                        error "WSO2 APIM installation not found at ${WSO2_HOME}"
                    }
                    
                    // Check if config directory exists
                    if (!fileExists(CONFIG_PATH)) {
                        error "WSO2 APIM config directory not found at ${CONFIG_PATH}"
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
                    
                    // Check service status
                    def serviceStatus = bat(
                        script: 'sc query "WSO2 API Manager" | find "RUNNING"',
                        returnStatus: true
                    )
                    
                    if (serviceStatus == 0) {
                        echo 'WSO2 APIM service is running successfully'
                    } else {
                        echo 'Warning: WSO2 APIM service status unclear'
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
            // You can add email notifications here
        }
        
        failure {
            echo 'Deployment failed!'
            // You can add failure notifications here
        }
    }
}
