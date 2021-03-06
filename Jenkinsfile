pipeline {
  agent any
  stages{
    stage('Build-1') {
       steps {
         slackSend channel: 'notify', message: 'Performance Testing started: ${BUILD_NUMBER}'
           echo 'Building......'
         slackSend channel: 'notify', message: 'Performance Testing ended: ${BUILD_NUMBER}'
       }
    }
  }
}
