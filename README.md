# project-kaiwa

# Abschlussprojekt – DevOps- und Cloud Engineering (README ist noch in Bearbeitung 22.04.25)

Im Rahmen meiner Weiterbildung zum **Dev/Ops- und Cloud Engineer** bei der Techstarter GmbH (15.04.2024 – 09.04.2025) habe ich zusammen mit 2 Kurs-Teilnehmern, während eines Gruppen-Projekts eine eigene Chat-App mit React und Socket.io entwickelt, die über eine WebSocket-Verbindung kommuniziert. Das Projekt wurde in einem Scrum-Prozess aufgebaut und nutzt React, Socket.io, Express.js, SQLite und Nginx auf einer AWS EC2-Instanz. Mein Schwerpunkt lag auf der Umsetzung der Business-Logik, der Integration der WebSocket-Kommunikation, dem Aufbau des Express-Servers sowie der Nginx-Konfiguration und dem Deployment.

Im Rahmen meines Abschlussprojekts habe ich die bestehende App weiterentwickelt und um moderne DevOps-Komponenten erweitert. Dazu gehören:
- ein vollständiges **automatisches Deployment mit Containerisierung, Terraform und Ansible**.
- eine automatisierte **CI/CD-Pipeline mit Jenkins**,
- sowie ein umfassendes **Monitoring mit Prometheus und Grafana**,

Das Projekt zielt darauf ab, ein realitätsnahes Setup für den professionellen Einsatz zu gestalten. Dabei war mir besonders wichtig, dass alle Prozesse automatisiert, reproduzierbar und verständlich dokumentiert sind. Die Infrastruktur besteht aus einer Dev- und einer Prod-Umgebung. Für das Infrastruktur-Setup habe ich Terraform eingesetzt. Ansible kommt für die Provisionierung und Konfiguration der Systeme zum Einsatz.

Ein zentraler Fokus liegt auf der Frage, wie Tools wie **Terraform, Jenkins und Ansible sinnvoll zusammenarbeiten** – nicht nur als Einzelkomponenten, sondern als integriertes, robustes System. Dabei wurde das komplette Setup so aufgebaut, dass es von Grund auf automatisiert ist: von der Jenkins-Installation bis zum finalen Deployment der containerisierten Applikation.

Die CI/CD-Pipeline ist dabei so aufgebaut, dass beim Push in den Dev-Branch die App getestet, gebaut und direkt deployed wird. Beim Push in den Main-Branch erfolgt zusätzlich ein containerisiertes Deployment über Docker Hub und Docker Compose. Die Erreichbarkeit der App wird nach jedem Schritt automatisch geprüft.

Auch das Monitoring wurde so einfach und effektiv wie möglich umgesetzt. Prometheus läuft auf einer der App-Instanzen, Grafana im Docker-Container, und der Node Exporter auf allen Hosts. Zusätzlich sendet der Express-Server Metriken via `prom-client` – z. B. wie viele Nutzer gerade angemeldet sind, wie viele sich jemals angemeldet haben, wie viele Nachrichten versendet wurden und wie viele davon in der letzten Stunde. Auch Jenkins ist ins Monitoring eingebunden.

Das komplette Projekt ist so dokumentiert, dass es leicht auf anderen Systemen wiederverwendet werden kann. Der Fokus liegt auf realistischen, produktionsnahen Szenarien – genau so, wie ich sie später auch im Berufsleben umsetzen möchte.


---

## Projektziele

- Aufbau einer **vollständigen CI/CD-Pipeline** mit Jenkins
- **Automatisches Deployment** bei Änderungen in verschiedenen Branches
- Einführung von **Containerisierung** für Produktionsumgebungen
- Trennung von **Dev- und Prod-Umgebungen**
- Implementierung eines **Monitoring-Stacks** mit Prometheus und Grafana
- Nutzung von **Infrastructure as Code** (Terraform, Ansible)
- Einrichtung einer produktionsnahen Infrastruktur auf AWS und Azure

---

## Architektur

Die Architektur besteht aus mehreren virtuellen Maschinen in der Cloud, die unterschiedliche Aufgaben erfüllen:

| Komponente          | Beschreibung                                                                 |
|---------------------|------------------------------------------------------------------------------|
| Jenkins-Server      | Führt alle CI/CD-Prozesse aus                                                |
| Jenkins-Node        | Unterstützt Jenkins bei Build- und Deploymentprozessen                       |
| EC2 Dev             | Direkter Deployment-Host für die Entwicklungsumgebung                        |
| EC2 Prod            | Containerisiertes Deployment über Docker Compose                             |
| Monitoring-Server   | Läuft auf App-EC2, beherbergt Prometheus und Grafana                         |

Weitere Bestandteile:

- **Ansible**: Automatisierte Einrichtung von Jenkins, Plugins, Deployments, Monitoring, Konfigurationen
- **Terraform**: Bereitstellung der Infrastruktur (Azure und AWS)
- **Docker**: Containerisierung für die Prod-Umgebung
- **GitHub**: Versionierung & `Jenkinsfile` als zentrale Pipeline-Definition
- **Express.js Metrics**: Nutzung von `prom-client` für eigene Metriken

---

## CI/CD-Pipeline im Überblick

Die CI/CD-Pipeline ist branch-basiert aufgebaut:

### Development-Branch

- Trigger: Push auf `dev`
- Schritte:
  1. Testausführung (API, Socket.io)
  2. Build der App
  3. Deployment auf die Dev-Instanz (EC2, ohne Container)
  4. Erreichbarkeitsprüfung

### Main-Branch (Production)

- Trigger: Push auf `main`
- Schritte:
  1. Testausführung (wie oben)
  2. Build
  3. Containerisierung der App
  4. Push zu Docker Hub
  5. Deployment per `docker-compose` auf Prod-Instanz
  6. Erreichbarkeitsprüfung

---

## Monitoring

Der Monitoring-Stack besteht aus:

- **Prometheus** (läuft auf App-EC2)
- **Grafana** (Docker-Container)
- **Node Exporter** (auf allen relevanten Instanzen)
- **Jenkins Prometheus Plugin** für CI/CD-bezogene Metriken
- **Express.js eigene Metriken**:
  - Aktuell eingeloggte User
  - Gesamtanzahl eingeloggter User
  - Gesamtanzahl gesendeter Nachrichten
  - Nachrichtenanzahl der letzten Stunde

---

## Anleitung zur Ausführung

Eine detaillierte Anleitung zur Inbetriebnahme (inkl. Terraform, Ansible, Jenkins, Deployment, Monitoring) folgt im unteren Teil der README – mit klaren Schritten zur Reproduktion auf eigener Infrastruktur oder in der Cloud.

---

> Das vollständige Projekt inkl. Code findest du im Repository:
> 👉 [GitHub: Kaiwa Chat-App mit DevOps-Pipeline](https://github.com/marcusBieber/Kaiwa)

---

Möchtest du jetzt, dass ich direkt den nächsten Teil – die **technische Anleitung zur Ausführung** – in diesem Stil fertig schreibe?
