pipeline {
  agent any
  tools { 
    maven 'Maven3.6.3' 
    jdk 'JDK' 
  }
  stages{
    stage('Sonar Qube Analysis') {
      steps {
        withSonarQubeEnv(installationName: 'sonarqube-server') { 
          sh '''
            echo "PATH = ${PATH}"
            echo "M2_HOME = ${M2_HOME}"
            mvn "-Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java " -Dsonar.login=sonar -Dsonar.password=${SONAR_AUTH} -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.sources=. sonar:sonar -Dsonar.host.url=${SONAR_HOST_URL}
            '''
        }
      }
    }
    stage('Build the project') {
      steps {
        script { 
          sh '''
            mvn -B -f pom.xml compile
            '''
        }
      }
    }
    stage('UI Test') {
      steps {
        script { 
          sh '''
            mvn -B -f functionaltest/pom.xml test
            '''
        }
      }
    }

  }
  
      
  // post {
  //   always {
  //     jiraSendBuildInfo(site: 'devopsbctcs03.atlassian.net', branch: 'matser')
  //   }
  // }
  environment {
    SONAR_AUTH=credentials('sonar-login')
  }
}
