pipeline {
	agent any

	environment {
		OCP_SERVER = 'https://console-openshift-console.apps-crc.testing'
		OCP_PROJECT = 'sanjeeb-mallick'
		//OCP_TOKEN = credentials('ocp-token-id')  // Jenkins credential ID
	}

	stages {
		stage('Checkout') {
			steps {
				checkout scm
			}
		}

		stage('Build') {
			steps {
				sh './mvnw clean package -DskipTests'
			}
		}

		stage('Unit Tests') {
			steps {
				sh './mvnw test'
			}
		}

		stage('Docker Build & Push') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'docker-hub',
					usernameVariable: 'DOCKER_USER',
					passwordVariable: 'DOCKER_PASS')]) {
					sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t $DOCKER_USER/your-app:${BUILD_NUMBER} .
                        docker push $DOCKER_USER/your-app:${BUILD_NUMBER}
                    '''
				}
			}
		}

		stage('Deploy to OpenShift') {
			steps {
				sh '''
                oc login $OCP_SERVER --token=$OCP_TOKEN
                oc project $OCP_PROJECT
                oc set image deployment/your-app your-app=your-registry/your-app:${BUILD_NUMBER} --record
                oc rollout status deployment/your-app
                '''
			}
		}
	}
}