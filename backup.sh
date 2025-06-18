#!/bin/bash
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
BACKUP_DIR="$BASE_DIR/backups"
COMP_DIR="$BACKUP_DIR/compressed"
UNCOMP_DIR="$BACKUP_DIR/uncompressed"
MAINDIR="/home/sam/wordpress"
LOGFILE="backup.log"
DBCON="wp_db"
WPCON="wp_app"
SUBJECT="BACKUP FOR $TIMESTAMP"
EMAIL="youremail@gmail.com"
cowsay "Starting Backup ..." 
echo "Starting Backup ..." > "$LOGFILE"
cowsay "Back up start at $TIMESTAMP"
echo "Back up start at $TIMESTAMP" >> "$LOGFILE"

cowsay "Processing . . ."
echo "Processing . . ."  >> "$LOGFILE"
DIR="/home/sam/backup/backup_files"
DIRUN="$DIR/backup_uncompress"
DBUSER="root"
DBPW="root_pass"
if [ ! -d "$DIR" ]; then
    cowsay "Creating Directory ..."
    echo "Creating Directory $DIR and $DIRUN..."  >> "$LOGFILE"
    mkdir -p "$DIR"
else
    :
fi

if [ ! -d "$DIRUN" ]; then
	mkdir "$DIRUN"
fi
docker exec "$DBCON" mysqldump -u $DBUSER -p$DBPW wp_db > "$DIRUN/backup.sql"
cowsay "Complete to backup database. You can find it at $DIRUN . starting to backup wordpress . . . "
echo "Complete to backup database. You can find it at $DIRUN . starting to backup wordpress . . ." >> "$LOGFILE"

docker cp "$WPCON:/var/www/html/wp-content" "$DIRUN/wp-content"
docker cp  "$WPCON:/var/www/html/wp-config.php" "$DIRUN"

cowsay "Done! Starting to backup docker files"
echo "Done! Starting to backup docker files" >> "$LOGFILE"
cp -r "$MAINDIR/docker-compose.yml" "$DIRUN/"
cp -r "$MAINDIR/nginx.conf" "$DIRUN/"
cp -r "$MAINDIR/ssl" "$DIRUN/"
cowsay "Done. Compressing..."
echo "Done. Compressing..." >> "$LOGFILE"
tar -czf "$DIR/$TIMESTAMP-wordpress.tar.gz" -C "$DIRUN" .
cowsay "Compressing Done i will send you an email for this backup :)"
echo "Compressing Done at $TIMESTAMP"
cowsay "Backup Done" >> "$LOGFILE"
cat "$LOGFILE" | mail -s "$SUBJECT" "$EMAIL"
#cowsay "Backup Done" >> "$LOGFILE"
cowsay "See you later" 

