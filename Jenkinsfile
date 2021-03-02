pipeline {
  agent any
  stages {
    stage('Sonar Qube Analysis') {
      withSonarQubeEnv(credentialsId: 'a802ff2c895911f06c87a736ee911f1a46d27fb6', installationName: 'sonarqube-scanner') { // You can override the credential to be used
      sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:4.6.0.2311:sonar'
    }
      post {
        always {
        jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net', branch: 'matser')
        }
      }
    }

  }
}
