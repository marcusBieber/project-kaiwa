pipeline {
    agent any  // Führe die Pipeline auf einem beliebigen verfügbaren Agenten aus

    parameters {
        choice(
            name: 'TARGET_BRANCH',
            choices: ['none', 'main', 'dev'],  // 'none' für automatische Trigger
            description: 'Wähle die Branch aus, für die die Aktionen ausgeführt werden sollen (nur für manuelle Trigger).'
        )
    }

    environment {
        // Umgebungsvariablen für die Pipeline
        GIT_BRANCH = "${params.TARGET_BRANCH != 'none' ? params.TARGET_BRANCH : env.GIT_BRANCH}"  // Verwendet den Parameter oder die aktuelle Branch
    }

    stages {
        stage('Check Branch') {
            steps {
                script {
                    // Überprüfe, welche Branch aktiv ist
                    if (env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main') {
                        echo "Push in die main-Branch erkannt oder manuell ausgewählt."
                        // Führe Aktionen für die main-Branch aus
                        stage('Main Branch Actions') {
                            echo "Starte Build für die main-Branch..."
                            sh 'echo "Führe Build-Schritte für die main-Branch aus..."'
                        }
                    } else if (env.GIT_BRANCH == 'origin/dev' || env.GIT_BRANCH == 'dev') {
                        echo "Push in die dev-Branch erkannt oder manuell ausgewählt."
                        // Führe Aktionen für die dev-Branch aus
                        stage('Dev Branch Actions') {
                            echo "Starte Build für die dev-Branch..."
                            sh 'echo "Führe Build-Schritte für die dev-Branch aus..."'
                        }
                    } else {
                        echo "Unbekannte Branch erkannt oder ausgewählt: ${env.GIT_BRANCH}"
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