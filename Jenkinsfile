def server
def buildInfo
def rtMaven
pipeline {
  agent any
  stages {
    stage('Initalize') {
      parallel {
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
        stage('Initalize Docker on Test & Prod Servers') {
          steps {
            slackSend channel: 'notify', message: "Initialize Test & Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            script {
              sh '''
                  testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
                  prodserver=`grep prod-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
                  for server in $testserver $prodserver
                  do
                    sudo ssh -o StrictHostKeyChecking=no root@${server} '
                      if [[ `docker ps -q | wc -l` -gt 0 ]]
                      then 
                        docker container stop $(docker ps -q )
                        docker run -v /opt/tomcat/webapps:/usr/local/tomcat/webapps -v /opt/tomcat/logs:/usr/local/tomcat/logs -p 8080:8080 -it -d tomcat:8-jdk8-openjdk-slim
                        docker run -d -e POSTGRES_PASSWORD=password -e PGDATA=/var/lib/postgresql/data/pgdata -v /opt/postgresql:/var/lib/postgresql/data -p 5432:5432 devopsbcsquad5/postgresdbsquad5 
                        chown -R 777 /opt/tomcat /opt/postgresql
                      else 
                        docker run -v /opt/tomcat/webapps:/usr/local/tomcat/webapps -v /opt/tomcat/logs:/usr/local/tomcat/logs -p 8080:8080 -it -d tomcat:8-jdk8-openjdk-slim
                        docker run -d -e POSTGRES_PASSWORD=password -e PGDATA=/var/lib/postgresql/data/pgdata -v /opt/postgresql:/var/lib/postgresql/data -p 5432:5432 devopsbcsquad5/postgresdbsquad5 
                        chown -R 777 /opt/tomcat /opt/postgresql
                      fi
                    '
                  done
                '''
            }
          }
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
              grep URL functionaltest/src/test/java/functionaltest/ftat.java
              grep URL Acceptancetest/src/test/java/acceptancetest/acat.java 
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
      
    stage('Deploy on Test Server') {
      steps {
        slackSend channel: 'notify', message: "Deployment of War on Test Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              sudo ansible-playbook -e 'deployservers="test-server" lcp="QA"' dwnldArtifact.yml
              sleep 20s
            '''
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
               jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-${env.BUILD_NUMBER}', environmentName: 'testserver', environmentType: 'testing', issueKeys: ['DP-2']
           }
       }
    }

    stage('Performance test'){
        steps {
            slackSend channel: 'notify', message: "Performance Testing started for build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            blazeMeterTest credentialsId: 'Blazemeter', testId: '9137429.taurus', workspaceId: '775624'
        }
    }

   stage('Deploy on Prod Server') {
      steps {
        slackSend channel: 'notify', message: "Deployment of War on Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              sudo ansible-playbook -e 'deployservers="prod-server" lcp="Prod"' dwnldArtifact.yml
              sleep 20s
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
               jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'prod-${env.BUILD_NUMBER}', environmentName: 'prodserver', environmentType: 'production', issueKeys: ['DP-2']
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
