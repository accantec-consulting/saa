#!/bin/bash
 
# Update und Installation von notwendigen Tools
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv git
 
# Projektverzeichnis erstellen
PROJECT_DIR="/home/ubuntu/streamlit_app"
mkdir -p $PROJECT_DIR
 
# Dateien aus dem GitHub-Repository herunterladen
GIT_REPO="https://github.com/accantec-consulting/saa.git"
BRANCH="develop"
TEMP_DIR="/tmp/saa_repo"
 
# Repository klonen und Dateien kopieren
git clone --branch $BRANCH $GIT_REPO $TEMP_DIR
cp $TEMP_DIR/saa_frontend/app.py $PROJECT_DIR/
cp $TEMP_DIR/saa_frontend/requirements.txt $PROJECT_DIR/
 
# Virtuelle Umgebung erstellen
python3 -m venv $PROJECT_DIR/venv
 
# Aktivieren der virtuellen Umgebung
source $PROJECT_DIR/venv/bin/activate
 
# Abhängigkeiten in der virtuellen Umgebung installieren
pip install -r $PROJECT_DIR/requirements.txt
 
# Deaktivieren der virtuellen Umgebung
deactivate
 
# Systemd-Service für die Streamlit-App erstellen
SERVICE_FILE="/etc/systemd/system/streamlit.service"
echo "[Unit]
Description=Streamlit App
After=network.target
 
[Service]
ExecStart=$PROJECT_DIR/venv/bin/python -m streamlit run $PROJECT_DIR/app.py --server.port=8501 --server.headless=true
Restart=always
User=ubuntu
Environment=PYTHONUNBUFFERED=1
 
[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE
 
# Streamlit-Service aktivieren und starten
sudo systemctl daemon-reload
sudo systemctl start streamlit.service
sudo systemctl enable streamlit.service
 
# Bereinigung
rm -rf $TEMP_DIR
 
echo "Streamlit-App erfolgreich eingerichtet und gestartet!"