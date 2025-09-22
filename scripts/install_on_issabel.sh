#!/bin/bash
set -euo pipefail

# pbx-scheduler-paging installer for Issabel server
# - must be run as root
# - detects apt or yum/dnf

if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

REPO_URL="https://github.com/blackdoost/pbx-scheduler-paging.git"
INSTALL_DIR="/opt/pbx-scheduler-paging"
MEDIA_DIR="/var/lib/pbx-scheduler-paging/media"
SERVICE_FILE="/etc/systemd/system/pbx-scheduler.service"
VENV_DIR="$INSTALL_DIR/venv"

function run_apt() {
  apt-get update
  apt-get -y upgrade
  apt-get install -y git python3 python3-venv python3-pip ffmpeg mariadb-client
}

function run_yum() {
  # enable EPEL
  if ! rpm -q epel-release >/dev/null 2>&1; then
    yum install -y epel-release || true
  fi
  # try to enable RPM Fusion for ffmpeg if ffmpeg not available
  if ! yum list installed ffmpeg >/dev/null 2>&1 && ! yum --showduplicates list ffmpeg >/dev/null 2>&1; then
    if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
      yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm || true
    fi
  fi
  yum -y update
  yum install -y git python3 python3-pip ffmpeg mariadb
}

function run_dnf() {
  dnf -y upgrade
  dnf install -y git python3 python3-venv python3-pip ffmpeg mariadb
}

PKG_MANAGER=""
if command -v apt-get >/dev/null 2>&1; then
  PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
  PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MANAGER="yum"
else
  echo "No supported package manager found (apt, dnf, yum). Install prerequisites manually." >&2
  exit 1
fi

echo "Using package manager: $PKG_MANAGER"
if [[ "$PKG_MANAGER" == "apt" ]]; then
  run_apt
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
  run_dnf
else
  run_yum
fi

# Clone or update repository
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Repository already exists in $INSTALL_DIR, pulling latest changes"
  cd "$INSTALL_DIR"
  git fetch --all
  git reset --hard origin/main || git pull --rebase
else
  echo "Cloning repository into $INSTALL_DIR"
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Create media directory
mkdir -p "$MEDIA_DIR"
# Set ownership to asterisk if user exists, otherwise current user
if id -u asterisk >/dev/null 2>&1; then
  chown -R asterisk:asterisk "$INSTALL_DIR" "$MEDIA_DIR"
else
  chown -R $(logname 2>/dev/null || $SUDO_USER || root):$(logname 2>/dev/null || $SUDO_USER || root) "$INSTALL_DIR" "$MEDIA_DIR" || true
fi
chmod -R 750 "$INSTALL_DIR" "$MEDIA_DIR" || true

# Create Python virtualenv and install requirements if any
if command -v python3 >/dev/null 2>&1; then
  if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
  fi
  source "$VENV_DIR/bin/activate"
  pip install --upgrade pip setuptools wheel
  if [[ -f "$INSTALL_DIR/requirements.txt" ]]; then
    pip install -r "$INSTALL_DIR/requirements.txt"
  fi
  deactivate || true
fi

# Create systemd service
cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=PBX Scheduler & Paging backend
After=network.target

[Service]
Type=simple
User=asterisk
Group=asterisk
WorkingDirectory=/opt/pbx-scheduler-paging
ExecStart=/opt/pbx-scheduler-paging/venv/bin/python3 /opt/pbx-scheduler-paging/src/scheduler.py
Restart=on-failure
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable --now pbx-scheduler.service || systemctl start pbx-scheduler.service || true

echo "\nInstallation complete. Next manual steps:\n"
echo "- Verify AMI credentials and add AMI user in /etc/asterisk/manager.conf or manager.d (user: pbxsch)."
echo "- If you want the service to run as 'asterisk' user, ensure that user exists and has permissions."
echo "- Apply DB schema: mysql -u root -p < $INSTALL_DIR/db/schema.sql or use your Issabel DB."
echo "- Edit /opt/pbx-scheduler-paging/src/ami_client.py to set AMI credentials and test connectivity."
echo "- Ensure ffmpeg is installed and working: ffmpeg -version"

echo "If any step failed, check /var/log/syslog or journalctl -u pbx-scheduler.service for logs."