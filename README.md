# project-kaiwa

# Abschlussprojekt – DevOps-basierte Weiterentwicklung einer Chat-App

Dieses Projekt ist im Rahmen meiner Weiterbildung zum **DevOps- und Cloud Engineer** bei der [Techstarter GmbH](https://techstarter.de/) (15.04.2024 – 09.04.2025) entstanden. Die Weiterbildung vermittelt fundierte Kenntnisse in moderner Cloud-Infrastruktur, CI/CD-Pipelines, Automatisierung und Webentwicklung. In meinem Abschlussprojekt setze ich diese Kompetenzen gezielt ein, um eine bereits entwickelte Chat-Applikation umfassend weiterzuentwickeln – mit einem besonderen Fokus auf Automatisierung, Monitoring, Skalierbarkeit und Best Practices im DevOps-Bereich.

---

## Projektüberblick

Im Zentrum des Projekts steht eine eigenentwickelte Chat-Anwendung (React, Express.js, Socket.io, SQLite), die in mehreren Schritten modernisiert, automatisiert und produktionsreif gemacht wurde. Ziel war es, ein realistisches, gut nachvollziehbares und erweiterbares Setup zu schaffen, das zentrale Anforderungen aus dem Berufsalltag eines DevOps Engineers widerspiegelt.

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
