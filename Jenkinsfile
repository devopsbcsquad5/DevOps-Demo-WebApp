def server
def buildInfo
def rtMaven
pipeline {
  agent any
  stages {
    stage('Static Code Analysis') {
      steps {
        slackSend channel: 'notify', message: "Static Code Analysis started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
        slackSend channel: 'notify', message: "Build the project started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        script {
          sh '''
              mvn -B -f pom.xml compile
            '''
        }
      }
    }

    stage('Configure Test & Prod Server') {
      steps {
        slackSend channel: 'notify', message: "Configure Test & Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              prodserver=`grep prod-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              echo $testserver
              sed -i "s/squadtestserver/$testserver/g" $(find . -type f)
              sed -i "s/squadprodserver/$prodserver/g" $(find . -type f)
          '''
        }

      }
    }
    
    stage('Package the project') {
      steps {
        slackSend channel: 'notify', message: "Package the project started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              mvn package -Dmaven.test.skip=true
            '''
        }
      }
    }

    stage('Deploy on Test Server') {
      steps {
        slackSend channel: 'notify', message: "Deployment of War on Test Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              sudo ansible-playbook -e 'deployservers="test-server" lcp="QA"' dwnldArtifact.yml

            '''
        }
      }
    }
    stage('Store Artifacts') {
      steps {
        slackSend channel: 'notify', message: "Upload artifacts started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
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

    stage('UI Testing on Test Server') {
       steps {
           slackSend channel: 'notify', message: "UI Testing started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
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

   stage('Deploy on Prod Server') {
      steps {
        slackSend channel: 'notify', message: "Deployment of War on Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              sudo ansible-playbook -e 'deployservers="prod-server" lcp="Prod"' dwnldArtifact.yml
            '''
        }
      }
    }


    stage('Sanity Tests') {
       steps {
           slackSend channel: 'notify', message: "Sanity Testing on Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
           script {
               sh '''
               mvn -B -f Acceptancetest/pom.xml test
               '''
               }
           // publish html
           publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
       }
      post {
           always {
               jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'testserver', environmentType: 'testing', issueKeys: ['DP-2']
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
