pipeline {
  agent any
  stages {
    stage('Sonar Qube Analysis') {
      steps {
        withSonarQubeEnv(installationName: 'sonarqube-server') { 
          // You can override the credential to be used
          // sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:4.6.0.2311:sonar'
          println ${env.SONAR_HOST_URL} 
        }
      }
      
      // post {
      //   always {
      //     jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net', branch: 'matser')
      //   }
      // }
    }

  }
}
