pipeline {
    agent any

    parameters {
        choice(
            name: "TARGET_BRANCH",
            choices: ["none", "main", "dev"],
            description: "Wähle die Branch aus, für die die Aktionen ausgeführt werden sollen."
        )
    }

    environment {
        GIT_BRANCH = "${params.TARGET_BRANCH != 'none' ? params.TARGET_BRANCH : env.GIT_BRANCH}"
        EC2_USER = "ubuntu"
        EC2_HOST = "35.159.82.66"
        APP_URL = "http://${EC2_HOST}"
        APP_NAME = "kaiwa"
        DEPLOY_PATH = "/var/www/${APP_NAME}-frontend"
        BACKEND_PATH = "/var/www/${APP_NAME}-backend"
        SSH_CREDENTIALS = "jenkins-ec2-key"
    }

    tools {
        nodejs "NodeJS"
    }

    stages {
        stage("Check Branch") {
            steps {
                script {
                    echo "Aktuelle Branch: ${env.GIT_BRANCH}"
                }
            }
        }

        stage("Main Branch Actions") {
            when {
                expression { env.GIT_BRANCH == "origin/main" || env.GIT_BRANCH == "main" }
            }
            steps {
                echo "Starte Build für die main-Branch..."
                sh "echo 'Führe Build-Schritte für die main-Branch aus...'"
            }
        }

        stage("Dev Branch Actions") {
            when {
                expression { env.GIT_BRANCH == "origin/dev" || env.GIT_BRANCH == "dev" }
            }
            stages {
                stage("Clone Repository") {
                    steps {
                        git branch: "main",
                            url: "https://github.com/marcusBieber/kaiwa-next-level.git"
                    }
                }

                stage("Install Dependencies and Build React App") {
                    steps {
                        dir("frontend") {
                            sh """
                                npm install
                                npm run build
                            """
                        }
                    }
                }

                stage("Deploy Backend to EC2") {
                    steps {
                        sshagent(credentials: [SSH_CREDENTIALS]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                                    sudo mkdir -p ${BACKEND_PATH} &&
                                    sudo chown -R ubuntu:ubuntu ${BACKEND_PATH} &&
                                    sudo rm -rf ${BACKEND_PATH}/*'
                
                                scp -o StrictHostKeyChecking=no -r backend/database backend/server.js backend/package.json ${EC2_USER}@${EC2_HOST}:${BACKEND_PATH}

                                ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '

                                    cd ${BACKEND_PATH}/database && npm install
                                    cd ${BACKEND_PATH} && npm install

                                    if ! command -v pm2 &> /dev/null; then
                                        sudo npm install -g pm2
                                    fi

                                    pm2 start server.js --name "${APP_NAME}-backend"'
                            """
                        }
                    }               
                }
                
                stage("Deploy Frontend to EC2") {
                    steps {
                        sshagent(credentials: [SSH_CREDENTIALS]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                                    if ! command -v nginx &> /dev/null; then
                                        sudo apt update &&
                                        sudo apt install -y nginx &&
                                        sudo systemctl enable nginx &&
                                        sudo systemctl start nginx &&
                                        sudo rm -f /etc/nginx/sites-enabled/default
                                    fi &&
                                    
                                    sudo mkdir -p ${DEPLOY_PATH} &&
                                    sudo chown -R ubuntu:ubuntu ${DEPLOY_PATH} &&
                                    sudo rm -rf ${DEPLOY_PATH}/*'
                                
                                scp -o StrictHostKeyChecking=no -r frontend/dist/* ${EC2_USER}@${EC2_HOST}:${DEPLOY_PATH}

                                ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                                    sudo tee /etc/nginx/sites-available/${APP_NAME} > /dev/null <<EOT
server {
    listen 80;
    server_name _;

    location / {
        root ${DEPLOY_PATH};
        index index.html;
        try_files \\$uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /socket.io/ {
        proxy_pass http://localhost:3000/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_page 404 /index.html;
}
EOT
                                    sudo ln -sf /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/${APP_NAME} &&
                                    sudo systemctl restart nginx'
                            """
                        }
                    }
                }

                stage("Check Website Availability") {
                    steps {
                        script {
                            def response = sh(script: "curl -o /dev/null -s -w \"%{http_code}\" ${APP_URL}", returnStdout: true).trim()
                            if (response != "200") {
                                error("Website ist nicht erreichbar! HTTP-Status: ${response}")
                            } else {
                                echo "Website erfolgreich erreicht! HTTP-Status: ${response}"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline erfolgreich abgeschlossen!"
        }
        failure {
            echo "Pipeline fehlgeschlagen!"
        }
    }
}
