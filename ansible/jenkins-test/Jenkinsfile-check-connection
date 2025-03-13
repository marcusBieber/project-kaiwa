pipeline {
    agent any

    stages {
        stage('Check Connection') {
            steps {
                echo 'Verbindung zu GitHub erfolgreich!'
                echo 'Dieser Job wurde durch einen Push in das Repository ausgelöst.'
            }
        }
        stage('Show Date and Time') {
            steps {
                script {
                    def currentDate = new Date()
                    echo "Aktuelles Datum und Uhrzeit: ${currentDate}"
                }
            }
        }
    }
}