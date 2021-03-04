pipeline {
  agent any
  stages {
    // stage('Sonar Qube Analysis') {
    //   steps {
    //     withSonarQubeEnv('sonarqube-server') {
    //       sh '''
    //         echo "PATH = ${PATH}"
    //         echo "M2_HOME = ${M2_HOME}"
    //         mvn "-Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java " -Dsonar.login=sonar -Dsonar.password=${SONAR_AUTH} -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.sources=. sonar:sonar -Dsonar.host.url=${SONAR_HOST_URL}
    //       '''
    //     }

    //   }
    // }

    stage('Build the project') {
      steps {
        script {
          sh '''
              mvn -B -f pom.xml compile
            '''
        }

      }
    }

    stage('Configure Test Server') {
      steps {
        script {
          sh '''
              gcloud auth activate-service-account --key-file=/var/lib/jenkins/workspace/gcloud_auth
              gcloud config set compute/zone us-central1-a
              testserver=`gcloud compute instances describe test-server --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
              sed -i "s/squadtestserver/$testserver/g" $(find . -type f)
              sudo ansible-playbook -e "myhostserver=test-server" TestServerCreation.yml
          '''
        }

      }
    }

    stage('Deploy War on Test server') {
      steps {
        script {
          sh """
            sudo ssh root@test-server -o StrictHostKeyChecking=no '
              git clone https://github.com/devopsbcsquad5/DevOps-Demo-WebApp.git
              cd DevOps-Demo-WebApp
              mvn package -Dmaven.test.skip=true
              cp "target/AVNCommunication-1.0.war" /var/lib/tomcat8/webapps/
              systemctl restart tomcat8
            '
          """
        }
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
