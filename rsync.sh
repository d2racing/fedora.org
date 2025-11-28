#!/bin/bash
echo 'start'
# ==========================================
# Sauvegarde NAS Synology -> Disque externe Btrfs (avec snapshots)
# ==========================================
# --- CONFIGURATION ---
NAS_IP="XXX.XXX.XXX.XXX"
NAS_USER="XXX"
NAS_PASS="XXX"
SHARES=("CLONEZILLA" "DIVERS" "DONNEES" "homes" "LOGICIELS" "photo" "PHOTOSYNC" "STORAGE_ANALYZER")
NAS_MOUNT_BASE="/mnt/nas"
MOUNT_POINT="/mnt/backup"
BACKUP_BASE="$MOUNT_POINT/nas_backup"
CURRENT="$BACKUP_BASE/current"
DATE=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT="$BACKUP_BASE/$DATE"
# --- VÉRIFICATION DU DISQUE EXTERNE ---
if ! mount | grep -q "$MOUNT_POINT"; then
    echo "Montage du disque externe..."
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount /dev/sdb1 "$MOUNT_POINT" || { echo "Erreur de montage du disque externe !"; exit 1; }
fi
# --- CRÉATION DU RÉPERTOIRE ACTUEL ---
sudo mkdir -p "$CURRENT"
# --- MONTAGE ET SYNCHRONISATION ---
for SHARE in "${SHARES[@]}"; do
    SRC="$NAS_MOUNT_BASE/$SHARE"
    DEST="$CURRENT/$SHARE"
    echo ">>> Montage de $SHARE..."
    sudo mkdir -p "$SRC"
    sudo mount -t cifs "//$NAS_IP/$SHARE" "$SRC" \
        -o username="$NAS_USER",password="$NAS_PASS",rw,iocharset=utf8,vers=3.0 || { echo "Échec du montage de $SHARE"; continue; }
    echo ">>> Synchronisation de $SHARE..."
    sudo mkdir -p "$DEST"
    sudo rsync -aHAX --no-xattrs --delete --exclude="#snapshot" --exclude="#recycle" --exclude="@eaDir/" --exclude="@recycle" --exclude="@tmp" --exclude=".SynoIndex*" --exclude="@__thumb/"  --info=progress2 "$SRC/" "$DEST/"
    echo ">>> Démontage de $SHARE..."
    sudo umount "$SRC"
done
# --- CRÉATION DU SNAPSHOT BTRFS ---
echo "Création du snapshot Btrfs : $SNAPSHOT"
echo $CURRENT
echo $SNAPSHOT
sudo btrfs subvolume snapshot -r "$CURRENT" "$SNAPSHOT" || { echo "Erreur lors du snapshot !"; exit 1; }
echo "Sauvegarde terminée le $DATE"

# sudo mkdir -p /mnt/backup
# sudo mount /dev/sdb1 /mnt/backup
# cd /mnt/backup
# sudo btrfs subvolume create nas_backup
# cd /mnt/backup/nas_backup
# sudo btrfs subvolume create current
# sudo btrfs subvolume snapshot -r /mnt/backup/nas_backup/current /mnt/backup/nas_backup/20251023

