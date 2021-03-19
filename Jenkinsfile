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
          post {
            success {
              slackSend channel: 'notify', message: "Static Code Analysis succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            }
            failure {
              slackSend channel: 'notify', message: "Static Code Analysis failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
          post {
            success {
              slackSend channel: 'notify', message: "Build the project succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            }
            failure {
              slackSend channel: 'notify', message: "Build the project failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            }
          }
        }
        stage('Initalize Docker Compose on Test & Prod Servers') {
          steps {
            slackSend channel: 'notify', message: "Initialize Test & Prod Server started for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            script {
              sh '''
                  testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
                  prodserver=`grep prod-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
                  for server in $testserver $prodserver
                  do
                    sudo scp -o StrictHostKeyChecking=no docker-compose.yml root@${server}:/root/docker-compose.yml
                    sudo ssh -o StrictHostKeyChecking=no root@${server} '
                      if [[ `docker ps -q | wc -l` -gt 0 ]]
                      then 
                        docker-compose down
                      fi
                      rm -fr /opt/tomcat/webapps/*
                      docker-compose up -d
                    '
                  done
                '''
            }
          }
          post {
            success {
              slackSend channel: 'notify', message: "Initialize Test & Prod Server succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            }
            failure {
              slackSend channel: 'notify', message: "Initialize Test & Prod Server failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
            }
          }
        }
      }
      post {
        success {
          script {
            sh '''
              ### Code to update the Story state
              story_nbr=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2 | cut -d '-' -f1`
              my_merge_branch=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2`
              curl -v -X PUT -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{"current_state":"finished"}' "${MY_PIVOTAL_STORIES}/${story_nbr}"

              ### Code to add the comments to the pivotal story
              curl -v -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{ "text":"Squad-5 Pipeline started due to new code merge to master from '${story_nbr}' in the github.\\n **BRANCH**:  '${my_merge_branch}' \\n **REPO**:  '${MY_REPO}'\\n \\n \\n Story status is updated to **FINISHED** " }' "${MY_PIVOTAL_STORIES}/${story_nbr}/comments"
            '''
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
              echo "Testserver: $testserver and Prodcution: $prodserver"
              sed -i "s/squadtestserver/$testserver/g" $(find . -type f)
              sed -i "s/squadprodserver/$prodserver/g" $(find . -type f)
              grep URL functionaltest/src/test/java/functionaltest/ftat.java
              grep URL Acceptancetest/src/test/java/acceptancetest/acat.java 
          '''
        }
      }
      post {
        success {
          slackSend channel: 'notify', message: "Configure Test & Prod Server succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Configure Test & Prod Server failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
      post {
        success {
          slackSend channel: 'notify', message: "Package the project succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Package the project failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
      post {
        success {
          slackSend channel: 'notify', message: "Upload artifacts succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Upload artifacts failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
      post {
        success {
          slackSend channel: 'notify', message: "Deployment of War on Test Server succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Deployment of War on Test Server failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
        success {
          slackSend channel: 'notify', message: "UI Testing succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "UI Testing failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
       }
    }

    stage('Performance test'){
      steps {
          slackSend channel: 'notify', message: "Performance Testing started for build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
          // blazeMeterTest credentialsId: 'Blazemeter', testId: '9137429.taurus', workspaceId: '775624'
          //blazeMeterTest credentialsId: 'bcb98eda-1130-4c9e-97e3-2262ffd3a6b7', testId: '9204220.taurus', workspaceId: '799387'
      }
      post {
        success {
          slackSend channel: 'notify', message: "Performance Testing succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
          script {
            sh '''
              ### Code to update the Story state
              story_nbr=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2 | cut -d '-' -f1`
              my_merge_branch=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2`
              curl -v -X PUT -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{"current_state":"delivered"}' "${MY_PIVOTAL_STORIES}/${story_nbr}"

              ### Code to add the comments to the pivotal story
              curl -v -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{ "text":"Squad-5 Pipeline deployed the new code to AWS Test-Server from artifactory using docker compose and ran the UI and Performance testing. \\n **Story ID**:  '${story_nbr}' \\n **BRANCH**:  '${my_merge_branch}' \\n **REPO**:  '${MY_REPO}'\\n \\n \\n Story status is updated to **DELIVERED** " }' "${MY_PIVOTAL_STORIES}/${story_nbr}/comments"
            '''
          }
        }
        failure {
          slackSend channel: 'notify', message: "Performance Testing failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
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
      post {
        success {
          slackSend channel: 'notify', message: "Deployment of War on Prod Server succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Deployment of War on Prod Server failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
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
        success {
          slackSend channel: 'notify', message: "Sanity Testing on Prod Server succesfully completed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
        failure {
          slackSend channel: 'notify', message: "Sanity Testing on Prod Server failed for : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
        }
      }
   }    
  
  }
  post {
    success {
      script {
        sh '''
            ### Code to update the Story CICD Pipeline status
            export story_nbr=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2 | cut -d '-' -f1`
            export NEW_LATEST_GIT_SHA=$(git rev-parse HEAD)
            my_merge_branch=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2`

            curl -v -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Content-Type: application/json" -d '{"status":"passed", "url":"'$BUILD_URL'", "uuid":"9c1a65985558b645d869c2adf0f162fc", "story_ids":['${story_nbr}'], "latest_git_sha":"'$NEW_LATEST_GIT_SHA'", "version":1}' "${MY_PIVOTAL_CICD}"
            
            curl -v -X PUT -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{"current_state":"accepted"}' "${MY_PIVOTAL_STORIES}/${story_nbr}"

            ### Code to add the comments to the pivotal story
            curl -v -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" --data '{ "text":"Squad-5 Pipelinedeployed the new code to AWS Prod-Server from artifactory using docker compose and completed the Sanity testing. Code is live to end-user \\n **Story ID**:  '{story_nbr}' \\n **BRANCH**:  '${my_merge_branch}' \\n **REPO**:  '${MY_REPO}'\\n \\n \\n Story status is updated to **ACCEPTED** " }' "${MY_PIVOTAL_STORIES}/{story_nbr}/comments"

            
        '''
      }
    }
    failure {
      script {
        sh '''
            ### Code to update the Story CICD Pipeline status
            export story_nbr=`git show ':/^Merge' --oneline| xargs| awk '{print $7}' | cut -d '/' -f2 | cut -d '-' -f1`
            export NEW_LATEST_GIT_SHA=$(git rev-parse HEAD)

            curl -v -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Content-Type: application/json" -d '{"status":"failed", "url":"'$BUILD_URL'", "uuid":"9c1a65985558b645d869c2adf0f162fc", "story_ids":['${story_nbr}'], "latest_git_sha":"'$NEW_LATEST_GIT_SHA'", "version":1}' "${MY_PIVOTAL_CICD}"
        '''
      }
    }
  }
  tools {
    maven 'Maven3.6.3'
    jdk 'JDK'
  }
  environment {
    SONAR_AUTH = credentials('sonar-login')
    TRACKER_API_TOKEN = credentials('tracker-api-token')
    MY_REPO="https://github.com/devopsbcsquad5/DevOps-Demo-WebApp"
    MY_PIVOTAL_CICD="https://www.pivotaltracker.com/services/v5/projects/2490801/cicd"
    MY_PIVOTAL_STORIES="https://www.pivotaltracker.com/services/v5/projects/2490801/stories"
  }
}
