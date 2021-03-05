pipeline {
  agent any
  stages {
    stage('Print Message') {
      steps {
        echo "Squad5 First blue ocean pipeline 3"
      }
    post {
      always {
        jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net', branch: 'matser')
      }
    }
  }
}
