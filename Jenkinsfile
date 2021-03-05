pipeline {
  agent any
  stages{
    stage('Build-1') {
       steps {
           echo 'Building......'
       }
       post {
           always {
               jiraSendBuildInfo site: 'devopsbctcs03.atlassian.net'
           }
       }
    }
    stage('test') {
       steps {
           echo 'Building......'
       }
       post {
           always {
               jiraSendBuildInfo site: 'devopsbctcs03.atlassian.net'
           }
       }
    }
 stage('Deploy') {
       steps {
           echo 'Building......'
       }
       post {
           always {
               jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'testcatalina', environmentType: 'testing', issueKeys: ['DP-2']
           }
       }
    }
  }  
}
