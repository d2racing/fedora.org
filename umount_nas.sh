#!/bin/bash
echo 'start'
# ==========================================
# Démontage du NAS
# ==========================================
# --- CONFIGURATION ---
SHARES=("CLONEZILLA" "DIVERS" "DONNEES" "homes" "LINUX" "LOGICIELS" "MACRIUM" "photo" "PHOTOSYNC" "STORAGE_ANALYZER")
NAS_MOUNT_BASE="/mnt/NAS"

# --- MONTAGE ET SYNCHRONISATION ---
for SHARE in "${SHARES[@]}"; do
    SRC="$NAS_MOUNT_BASE/$SHARE"
    echo ">>> Démontage de $SHARE..."
    sudo umount $SRC
done
