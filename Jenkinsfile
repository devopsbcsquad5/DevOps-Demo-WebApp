pipeline {
  agent any
  stages{
    stage('Build-1') {
       steps {
           echo 'Building......'
       }
       post {
           always {
               jiraSendBuildInfo site: 'devopsbctcs03.atlassian.net', issueKeys: ['DP-2']
           }
       }
    }
    stage('test') {
       steps {
           echo 'Building......'
       }
       post {
           always {
               jiraSendBuildInfo site: 'devopsbctcs03.atlassian.net', issueKeys: ['DP-2']
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
