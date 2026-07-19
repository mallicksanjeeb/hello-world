pipeline {
	agent any

	environment {
		PATH = "/usr/local/bin:${env.PATH}"
		OCP_SERVER = 'https://api.crc.testing:6443'
		OCP_PROJECT = 'sanjeeb-mallick-ocp-namespace'
		OCP_TOKEN = credentials('ocp-token-id')  // Jenkins credential ID
		//Adjust path if you store ca.crt elsewhere
		OCP_CA = "/Users/sk/ca.crt"
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

		stage('Check PATH') {
			steps {
				sh 'echo $PATH'
			}
		}

		stage('Check Docker') {
			steps {
				sh '/usr/local/bin/docker version'
			}
		}

		stage('Docker Build & Push') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'docker-hub',
					usernameVariable: 'DOCKER_USER',
					passwordVariable: 'DOCKER_PASS')]) {
					sh '''
                        echo "$DOCKER_PASS" | /usr/local/bin/docker login -u "$DOCKER_USER" --password-stdin
                        /usr/local/bin/docker build -t $DOCKER_USER/hello-world-0.0.1-snapshot:${BUILD_NUMBER} .
                        /usr/local/bin/docker push $DOCKER_USER/hello-world-0.0.1-snapshot:${BUILD_NUMBER}
                    '''
				}
			}
		}

		stage('Check oc') {
			steps {
				sh '/opt/homebrew/bin/oc version'
			}
		}

		stage('Login to OpenShift') {
			steps {
				withCredentials([
					string(credentialsId: 'ocp-token-id', variable: 'OCP_TOKEN'),
					file(credentialsId: 'ocp-ca', variable: 'OCP_CA')
				]) {
					sh '''
                        echo "Logging into local OCP cluster..."
                        /opt/homebrew/bin/oc login $OCP_SERVER \
                          --token=$OCP_TOKEN \
                          --certificate-authority=$OCP_CA \
                          --insecure-skip-tls-verify=true
                    '''
				} /*{
					sh '''
                        echo "Logging into OpenShift..."
                        /opt/homebrew/bin/oc login $OCP_SERVER
                          --token=$OCP_TOKEN \
                          --certificate-authority=$OCP_CA
                    '''
				}*/
			}
		}

		stage('Deploy to OpenShift') {
			steps {
				sh '''
                    echo "Deploying application..."
                    /opt/homebrew/bin/oc project $OCP_PROJECT
                    /opt/homebrew/bin/oc apply -f openshift/deployment.yaml
                    /opt/homebrew/bin/oc set image dockerforsanjeeb/hello-world-0.0.1-snapshot hello-world-0.0.1-snapshot=hello-world-0.0.1-snapshot/hello-world-0.0.1-snapshot:${BUILD_NUMBER} --record
                	/opt/homebrew/bin/oc rollout status dockerforsanjeeb/hello-world-0.0.1-snapshot
                '''
			}
		}

		/*stage('Deploy to OpenShift') {
			steps {
				sh '''
				echo "Deploying application..."
                /opt/homebrew/bin/oc login $OCP_SERVER --token=$OCP_TOKEN
                /opt/homebrew/bin/oc project $OCP_PROJECT
                /opt/homebrew/bin/oc set image deployment/hello-world-0.0.1-snapshot hello-world-0.0.1-snapshot=hello-world-0.0.1-snapshot/hello-world-0.0.1-snapshot:${BUILD_NUMBER} --record
                /opt/homebrew/bin/oc rollout status deployment/hello-world-0.0.1-snapshot
                '''
			}
		}*/
	}
}