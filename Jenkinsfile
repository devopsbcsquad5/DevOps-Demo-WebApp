pipeline {
  agent any
  stages{
    stage('Build-1') {
       steps {
         def buildid = ${env.BUILD_NUMBER}
         echo buildid
         slackSend channel: 'notify', message: 'Performance Testing ended: ${env.BUILD_NUMBER}'
           echo 'Building......'
         slackSend channel: 'notify', message: 'Performance Testing ended: ${env.BUILD_NUMBER}'
       }
    }
  }
}
