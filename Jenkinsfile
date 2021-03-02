pipeline {
  agent any
  stages {
    stage('Sonar Qube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube-server') {
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

    stage('Deploy To Test') {
      steps {
        script {
          sh '''
mvn -B -f pom.xml package
'''
        }

        sh 'docker build -t devops-docker-squad5-1 .'
      }
    }

  }
  tools {
    maven 'Maven3.6.3'
    jdk 'JDK'
  }
  environment {
    SONAR_AUTH = credentials('sonar-login')
  }
}