pipeline {
  agent { dockerfile true }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  parameters {
    string(name: 'IMAGE_REPO_NAME', defaultValue: '332011377173.dkr.ecr.us-east-1.amazonaws.com/lrcdn', description: '')
    string(name: 'LATEST_BUILD_TAG', defaultValue: 'latest', description: '')
    string(name: 'DOCKER_COMPOSE_FILENAME', defaultValue: 'docker-compose.yml', description: '')
    string(name: 'DOCKER_STACK_NAME', defaultValue: 'lsrcdn', description: '')
    booleanParam(name: 'DOTNET_RUN_TEST', defaultValue: true, description: '')
    booleanParam(name: 'PUSH_DOCKER_IMAGES', defaultValue: true, description: '')
    booleanParam(name: 'DOCKER_STACK_RM', defaultValue: false, description: 'Remove previous stack.  This is required if you have updated any secrets or configs as these cannot be updated. ')
  }
  stages { 

    stage('test'){
      agent {
          docker { 
	     image '332011377173.dkr.ecr.us-east-1.amazonaws.com/lrcdn'
	     customWorkspace "$JENKINS_HOME/workspace/$BUILD_TAG"
	  }
      }
      steps{
	 sh "pwd"
	 sh "sleep 30"
         sh "curl -I -f http://localhost:5000/v81/js/site.min.js || exit 1"
      }
    }
   stage('docker build'){
      environment {
        COMMIT_TAG = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
        BUILD_IMAGE_REPO_TAG = "${params.IMAGE_REPO_NAME}:${env.BUILD_TAG}"
      }
      steps{
	dir("$JENKINS_HOME/workspace/$BUILD_TAG"){	      
	  sh "pwd"
	  sh "sudo docker build . -t $BUILD_IMAGE_REPO_TAG"
	  sh "sudo docker tag $BUILD_IMAGE_REPO_TAG ${params.IMAGE_REPO_NAME}:$COMMIT_TAG"
	  sh "sudo docker tag $BUILD_IMAGE_REPO_TAG ${params.IMAGE_REPO_NAME}:${readJSON(file: 'package.json').version}"
	  sh "sudo docker tag $BUILD_IMAGE_REPO_TAG ${params.IMAGE_REPO_NAME}:${params.LATEST_BUILD_TAG}"
	  sh "sudo docker tag $BUILD_IMAGE_REPO_TAG ${params.IMAGE_REPO_NAME}:${env.BRANCH_NAME}-latest"
	}
      }
    }
    stage('docker push'){
      when{
        expression {
          return params.PUSH_DOCKER_IMAGES
        }
      }
      environment {
        COMMIT_TAG = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
        BUILD_IMAGE_REPO_TAG = "${params.IMAGE_REPO_NAME}:${env.BUILD_TAG}"
      }
      steps{
        sh "sudo docker push $BUILD_IMAGE_REPO_TAG"
        sh "sudo docker push ${params.IMAGE_REPO_NAME}:$COMMIT_TAG"
        sh "sudo docker push ${params.IMAGE_REPO_NAME}:${readJSON(file: 'package.json').version}"
        sh "sudo docker push ${params.IMAGE_REPO_NAME}:${params.LATEST_BUILD_TAG}"
        sh "sudo docker push ${params.IMAGE_REPO_NAME}:${env.BRANCH_NAME}-latest"
      }
    }
    stage('Remove Previous Stack'){
      when{
        expression {
	  return params.DOCKER_STACK_RM
        }
      }
      steps{
        sh "sudo docker stack rm ${params.DOCKER_STACK_NAME}"
	      
		      
      }
    }
    stage('Docker Stack Deploy'){
      steps{
        sh "sudo docker stack deploy -c ${params.DOCKER_COMPOSE_FILENAME} ${params.DOCKER_STACK_NAME}"
      }
    }
  }
  post {
    always {
      sh 'echo "This will always run"'
    }
  }
}
