#!/bin/bash
# =====================================================
# Vérification d'intégrité d'un disque Btrfs externe
# =====================================================

# --- CONFIGURATION ---
MOUNT_POINT="/mnt/backup"        # Point de montage du disque Btrfs
DEVICE="/dev/sdb1"               # Périphérique du disque
LOG_DIR="$HOME/btrfs_reports"    # Où stocker les rapports
DATE=$(date +%Y-%m-%d_%H-%M)
LOG_FILE="$LOG_DIR/btrfs_check_$DATE.log"

# --- PRÉPARATION ---
mkdir -p "$LOG_DIR"
echo "=== Rapport Btrfs du $DATE ===" > "$LOG_FILE"
echo "" >> "$LOG_FILE"

# --- ÉTAPE 1 : Vérifier si le disque est monté ---
if mount | grep -q "$MOUNT_POINT"; then
    echo "[OK] $MOUNT_POINT est monté." | tee -a "$LOG_FILE"
else
    echo "[INFO] Montage du disque $DEVICE sur $MOUNT_POINT..." | tee -a "$LOG_FILE"
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount "$DEVICE" "$MOUNT_POINT" || { echo "[ERREUR] Impossible de monter le disque !"; exit 1; }
fi

# --- ÉTAPE 2 : Lancer un SCRUB (vérification des checksums) ---
echo "" | tee -a "$LOG_FILE"
echo "=== Vérification des données et checksums (btrfs scrub) ===" | tee -a "$LOG_FILE"
time sudo btrfs scrub start -Bd "$MOUNT_POINT" | tee -a "$LOG_FILE"

# --- ÉTAPE 3 : Vérifier le statut du dernier scrub ---
echo "" | tee -a "$LOG_FILE"
echo "=== Résumé du dernier scrub ===" | tee -a "$LOG_FILE"
time sudo btrfs scrub status "$MOUNT_POINT" | tee -a "$LOG_FILE"

# --- ÉTAPE 4 : Vérifier les sous-volumes et snapshots ---
echo "" | tee -a "$LOG_FILE"
echo "=== Liste des sous-volumes Btrfs ===" | tee -a "$LOG_FILE"
time sudo btrfs subvolume list "$MOUNT_POINT" | tee -a "$LOG_FILE"

# --- ÉTAPE 5 : Vérification du système de fichiers (optionnel) ---
# ⚠️ À utiliser uniquement si le disque est démonté.
 echo "" | tee -a "$LOG_FILE"
 echo "=== Vérification structure interne (btrfs check) ===" | tee -a "$LOG_FILE"
 sudo umount "$MOUNT_POINT"
 sudo btrfs check "$DEVICE" | tee -a "$LOG_FILE"
 sudo mount "$DEVICE" "$MOUNT_POINT"

# --- FIN ---
echo "" | tee -a "$LOG_FILE"
echo "=== Vérification terminée le $DATE ===" | tee -a "$LOG_FILE"
echo "[✓] Rapport enregistré dans : $LOG_FILE"
