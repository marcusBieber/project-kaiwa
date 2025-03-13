pipeline {
    agent any  // Führe die Pipeline auf einem beliebigen verfügbaren Agenten aus

    environment {
        // Umgebungsvariablen für die Pipeline
        GIT_BRANCH = "${env.GIT_BRANCH}"  // Aktuelle Git-Branch
    }

    stages {
        stage('Check Branch') {
            steps {
                script {
                    // Überprüfe, welche Branch gepusht wurde
                    if (env.GIT_BRANCH == 'origin/main') {
                        echo "Push in die main-Branch erkannt."
                        // Führe Aktionen für die main-Branch aus
                        stage('Main Branch Actions') {
                            steps {
                                echo "Starte Build für die main-Branch..."
                                // Füge hier deine Build-Schritte für die main-Branch hinzu
                            }
                        }
                    } else if (env.GIT_BRANCH == 'origin/dev') {
                        echo "Push in die dev-Branch erkannt."
                        // Führe Aktionen für die dev-Branch aus
                        stage('Dev Branch Actions') {
                            steps {
                                echo "Starte Build für die dev-Branch..."
                                // Füge hier deine Build-Schritte für die dev-Branch hinzu
                            }
                        }
                    } else {
                        echo "Push in eine unbekannte Branch erkannt: ${env.GIT_BRANCH}"
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