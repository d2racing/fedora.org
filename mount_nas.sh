#!/bin/bash
echo 'start'
# ==========================================
# Montage du NAS
# ==========================================
# --- CONFIGURATION ---
NAS_IP="xxx.xxx.xxx.xxx"
NAS_USER="XXXX"
NAS_PASS="XXXX"
SHARES=("CLONEZILLA" "DIVERS" "DONNEES" "homes" "LINUX" "LOGICIELS" "MACRIUM" "photo" "PHOTOSYNC" "STORAGE_ANALYZER")
NAS_MOUNT_BASE="/mnt/NAS"

# --- MONTAGE ET SYNCHRONISATION ---
for SHARE in "${SHARES[@]}"; do
    SRC="$NAS_MOUNT_BASE/$SHARE"
    echo ">>> Montage de $SHARE..."
    sudo mkdir -p "$SRC"
    sudo mount -t cifs "//$NAS_IP/$SHARE" "$SRC" \
        -o username="$NAS_USER",password="$NAS_PASS",rw,iocharset=utf8,vers=3.0,uid=1000,gid=1000 || { echo "Échec du montage de $SHARE"; continue; }
done
