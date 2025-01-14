#!/bin/bash

# Update und Installation von notwendigen Tools
sudo apt update -y
sudo apt install -y python3 python3-pip unzip

# Projektverzeichnis erstellen
mkdir -p /home/ubuntu/streamlit_app

# Dateien ins Projektverzeichnis kopieren (da sie im User Data eingebettet werden)
cat <<EOF > /home/ubuntu/streamlit_app/app.py
$(cat ./saa_frontend/app.py)
EOF

cat <<EOF > /home/ubuntu/streamlit_app/requirements.txt
$(cat ./saa_frontend/requirements.txt)
EOF

# Virtuelle Umgebung erstellen
python3 -m venv /home/ubuntu/streamlit_app/venv
 
# Aktivieren der virtuellen Umgebung
source /home/ubuntu/streamlit_app/venv/bin/activate
 
# Abhängigkeiten in der virtuellen Umgebung installieren
pip install -r /home/ubuntu/streamlit_app/requirements.txt
 
# Deaktivieren der virtuellen Umgebung
deactivate

# # Virtuelle Umgebung und Abhängigkeiten installieren
# pip3 install -r /home/ubuntu/streamlit_app/requirements.txt

# Systemd-Service für die Streamlit-App erstellen
echo "[Unit]
Description=Streamlit App

[Service]
ExecStart=/home/ubuntu/streamlit_app/venv/bin/python -m streamlit run /home/ubuntu/streamlit_app/app.py --server.port=8501 --server.headless=true
Restart=always
User=ubuntu
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/streamlit.service

# Streamlit-Service aktivieren und starten
sudo systemctl daemon-reload
sudo systemctl start streamlit.service
sudo systemctl enable streamlit.service<
