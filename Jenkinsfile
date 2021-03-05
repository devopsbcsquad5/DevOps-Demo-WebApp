pipeline {
  agent any
  stage('Build') {
     steps {
         echo 'Building...'
     }
     post {
         always {
             jiraSendBuildInfo site: '<sitename>.atlassian.net'
         }
     }
  }
}
