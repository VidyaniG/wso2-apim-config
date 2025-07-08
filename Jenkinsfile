pipeline {
  agent any
  environment {
    JENKINS_NODE_COOKIE = 'dontKillMe' // protects background job
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Validate') {
      steps {
        script {
          if (!fileExists('deployment.toml')) error('Missing deployment.toml')
        }
      }
    }
    stage('Deploy') {
      steps {
        bat """
          call scripts\\deploy.bat
        """
      }
    }
  }
  post {
    always {
      echo 'Cleaning workspace'
      cleanWs()
    }
  }
}
