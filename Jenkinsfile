pipeline {
  agent any
  stages{
    stage('Build-1') {
       steps {
           echo 'Building......'
         slackSend channel: 'notify', message: 'Performance Testing started: ${env.JOB_NAME} ${env.BUILD_NUMBER}'
       }
    }
  }
}
