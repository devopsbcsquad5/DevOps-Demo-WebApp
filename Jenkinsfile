def server
def buildInfo
def rtMaven
pipeline {
  agent any
  stages {
    stage('Sonar Qube Analysis') {
      steps {
        slackSend channel: 'notify', message: "Sonar Qube Analysis started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
        slackSend channel: 'notify', message: "Build the project started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        script {
          sh '''
              mvn -B -f pom.xml compile
            '''
        }
      }
    }

    stage('Configure Test Server') {
      steps {
        slackSend channel: 'notify', message: "Configure Test Server started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              echo $testserver
              sed -i "s/squadtestserver/$testserver/g" $(find . -type f)
              #sudo ansible-playbook -e "myhostserver=test-server" TestServerCreation.yml
          '''
        }

      }
    }
    
    stage('Package the project') {
      steps {
        slackSend channel: 'notify', message: "Package the project started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              mvn package -Dmaven.test.skip=true
            '''
        }

      }
    }

    stage('Deploy War on Test Server') {
      steps {
        slackSend channel: 'notify', message: "Compile the project started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              #testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              #sudo scp -o StrictHostKeyChecking=no "target/AVNCommunication-1.0.war" root@$testserver:/var/lib/tomcat8/webapps/QAWebapp.war
              ansible-playbook dwnldArtifact.yml

            '''
        }
      }
    }
    stage('Store Artifacts') {
      steps {
        script {
            server = Artifactory.server 'artifactory'
            sh """ mvn package -Dmaven.test.skip=true """
            def uploadSpec = """{
            "files": [
                {
                  "pattern": "target/*.war",
                  "target": "squad5-libs-release-local"
                },
                {
                  "pattern": "target/*.war",
                  "target": "squad5-libs-snapshot-local"
                }
              ]
            }"""
            server.upload spec: uploadSpec

        }
      }
    }


    stage('UI Selenium Tests') {
       steps {
           slackSend channel: 'notify', message: "UI Testing started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
           script {
               sh '''
               mvn -B -f functionaltest/pom.xml test
               '''
               }
           // publish html
           publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\functionaltest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
       }
      post {
           always {
               jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'testserver', environmentType: 'testing', issueKeys: ['DP-2']
           }
       }
   }

    // stage('Performance test'){
    //     steps {
    //         slackSend channel: 'notify', message: "Performance Testing started for build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
    //         blazeMeterTest credentialsId: 'Blazemeter', testId: '9137429.taurus', workspaceId: '775624'
    //     }
    // }
    
    
    

  }
  tools {
    maven 'Maven3.6.3'
    jdk 'JDK'
  }
  environment {
    SONAR_AUTH = credentials('sonar-login')
  }
}
