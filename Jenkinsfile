pipeline {
  agent any
  tools { 
    maven 'Maven3.6.3' 
    jdk 'JDK' 
  }
  stages {
    stage('Print Message') {
      steps {
        echo "Squad5 First blue ocean pipeline"
      }
    }
      
    post {
      always {
        jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net', branch: 'matser')
      }
    }
  }
}
