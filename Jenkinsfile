pipeline {
  agent any
  tools { 
    maven 'Maven 3.6.3' 
    jdk 'jdk8' 
  }
  stages {
    stage('Sonar Qube Analysis') {
      steps {
        withSonarQubeEnv(installationName: 'sonarqube-server') { 
          // You can override the credential to be used
          sh '''
            echo "PATH = ${PATH}"
            echo "M2_HOME = ${M2_HOME}"
            mvn "-Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java " -Dsonar.login=sonar -Dsonar.password=sonar -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.sources=. sonar:sonar -Dsonar.host.url=${SONAR_HOST_URL}
            '''
          // println env.SONAR_HOST_URL 
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
