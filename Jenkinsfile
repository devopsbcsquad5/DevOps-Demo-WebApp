pipeline {
  agent any
  stages {
    stage('Build-1') {
      post {
        always {
          jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net')
        }

      }
      steps {
        echo 'Building......'
      }
    }

    stage('test') {
      post {
        always {
          jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net')
        }

      }
      steps {
        echo 'Building......'
        jiraSendBuildInfo(branch: 'DP-2', site: 'https://devopsbctcs03.atlassian.net/')
      }
    }

    stage('Deploy') {
      post {
        always {
          jiraSendDeploymentInfo(site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'testcatalina', environmentType: 'testing', issueKeys: ['DP-2'])
        }

      }
      steps {
        echo 'Building......'
      }
    }

  }
}