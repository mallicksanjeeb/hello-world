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

		stage('Build Docker Image') {
			steps {
				sh '''
                docker build -t your-registry/your-app:${BUILD_NUMBER} .
                docker push your-registry/your-app:${BUILD_NUMBER}
                '''
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