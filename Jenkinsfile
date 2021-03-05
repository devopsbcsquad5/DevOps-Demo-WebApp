pipeline {
  agent any
  stages{
    stage('Build') {
       steps {
           echo 'Building...'
       }
       post {
           always {
               jiraSendBuildInfo site: 'https://devopsbctcs03.atlassian.net'
           }
       }
    }
  }  
}
