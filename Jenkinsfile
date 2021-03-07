def server
def buildInfo
def rtMaven
pipeline {
  agent any
  stages {
    // stage('Sonar Qube Analysis') {
    //   steps {
    //     slackSend channel: 'notify', message: "Sonar Qube Analysis started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
    //     withSonarQubeEnv('sonarqube-server') {
    //       sh '''
    //         echo "PATH = ${PATH}"
    //         echo "M2_HOME = ${M2_HOME}"
    //         mvn "-Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java " -Dsonar.login=sonar -Dsonar.password=${SONAR_AUTH} -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.sources=. sonar:sonar -Dsonar.host.url=${SONAR_HOST_URL}
    //       '''
    //     }

    //   }
    // }

    // stage('Build the project') {
    //   steps {
    //     slackSend channel: 'notify', message: "Build the project started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}" 
    //     script {
    //       sh '''
    //           mvn -B -f pom.xml compile
    //         '''
    //     }
    //   }
    //   post {
    //       always {
    //           jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'Test', environmentType: 'testing', issueKeys: ['DP-2']
    //       }
    //   }    
    // }

    stage('Configure Test Server') {
      steps {
        slackSend channel: 'notify', message: "Configure Test Server started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        script {
          sh '''
              #gcloud auth activate-service-account --key-file=/var/lib/jenkins/workspace/gcloud_auth
              #gcloud config set compute/zone us-central1-a
              #testserver=`gcloud compute instances describe prod-server --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
              testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              echo $testserver
              sed -i "s/squadtestserver/$testserver/g" $(find . -type f)
              #sudo ansible-playbook -e "myhostserver=test-server" TestServerCreation.yml
          '''
        }

      }
    }
    
    stage('Build the project') {
      steps {
        slackSend channel: 'notify', message: "Compile the project started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
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
              testserver=`grep test-server /etc/ansible/hosts | awk '{print $2}' | cut -d '=' -f2`
              sudo scp -o StrictHostKeyChecking=no "target/AVNCommunication-1.0.war" root@$testserver:/opt/tomcat/webapps/QAWebapp.war

            '''
        }
      //   post {
      //      always {
      //          jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'Test', environmentType: 'testing', issueKeys: ['DP-2']
      //      }
      //   }  

      // }
    }

    // stage('Deploy War on Test server') {
    //   steps {
    //     script {
    //       sh """
    //         sudo ssh root@test-server -o StrictHostKeyChecking=no '
    //           git clone https://github.com/devopsbcsquad5/DevOps-Demo-WebApp.git
    //           cd DevOps-Demo-WebApp
    //           mvn package -Dmaven.test.skip=true
    //           cp "target/AVNCommunication-1.0.war" /var/lib/tomcat8/webapps/
    //           systemctl restart tomcat8
    //         '
    //       """
    //     }
    //   }
    // }
  //   stage('Store Artifacts') {
  //     steps {
  //       script {
  //           server = Artifactory.server 'artifactory'
  //           // rtMaven = Artifactory.newMavenBuild()
  //           // rtMaven.tool = 'Maven3.6.3' // Tool name from Jenkins configuration
  //           // rtMaven.deployer releaseRepo: 'squad5-libs-release-local', snapshotRepo: 'squad5-libs-snapshot-local', server: server
  //           // rtMaven.resolver releaseRepo: 'squad5-libs-release', snapshotRepo: 'squad5-libs-snapshot', server: server
  //           // rtMaven.deployer.deployArtifacts = false // Disable artifacts deployment during Maven run
  //           // buildInfo = Artifactory.newBuildInfo()
  //           // rtMaven.run pom: 'pom.xml', goals: 'clean test'
  //           // rtMaven.run pom: 'pom.xml', goals: 'install', buildInfo: buildInfo
  //           // rtMaven.deployer.deployArtifacts buildInfo
  //           //def uploadSpec = readFile 'target/
  //           //server.publishBuildInfo buildInfo
  //           sh """ mvn package -Dmaven.test.skip=true """
  //           def uploadSpec = """{
  //           "files": [
  //               {
  //                 "pattern": "target/*.war",
  //                 "target": "squad5-libs-release-local"
  //               },
  //               {
  //                 "pattern": "target/*.war",
  //                 "target": "squad5-libs-snapshot-local"
  //               }
  //             ]
  //           }"""
  //           server.upload spec: uploadSpec

  //       }
  //     }
  //   }
    // stage('Deploy War on Test server') {
    //   steps {
    //     // script {
    //     //   def downloadSpec = """{
    //     //   "files": [
    //     //         {
    //     //           "pattern": "target/*.war",
    //     //           "target": "squad5-libs-release-local"
    //     //         }
    //     //       ]
    //     //   }"""
    //     //   server.download spec: downloadSpec
    //       slackSend channel: 'notify', message: "Deploy War on Test server started for JOB and build : ${env.JOB_NAME} ${env.BUILD_NUMBER}"
    //       sh """
    //         sudo scp -o StrictHostKeyChecking=no "target/AVNCommunication-1.0.war" root@18.222.101.244:/var/lib/tomcat8/webapps/QAWebapp.war
    //         #sudo ssh root@18.222.101.244 -o StrictHostKeyChecking=no "
    //           #git clone https://github.com/devopsbcsquad5/DevOps-Demo-WebApp.git
    //           #cd DevOps-Demo-WebApp
    //           #curl -u deploy:'AKCp8ihLPHza9DUHyWNyeq9YND2aZCq91nFTUUiKuYCFomp27gU1GcG4HhqaUZitEiKp7xgrt' https://devopssquad5.jfrog.io/artifactory/squad5-libs-release-local/AVNCommunication-1.0.war -o /var/lib/tomcat8/webapps/AVNCommunication-1.0.war
    //           #systemctl restart tomcat8
    //           #sleep 10s
    //         #"
    //       """
    //     }
    //    post {
    //        always {
    //            jiraSendDeploymentInfo site: 'devopsbctcs03.atlassian.net', environmentId: 'test-1', environmentName: 'Test', environmentType: 'testing', issueKeys: ['DP-2']
    //        }
    //    }      
    //  }

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
