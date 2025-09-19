#!/bin/bash

backup_name="dumb-backup" # The backup name
dumb_password="dumb-password" # Just a dumb password for the Send link
serious_password="/path/to/really/serious/password.txt" # The file with a password to encrypt all your data with
send_instance="https://de.skysend.ch/" # The Send instance to send the backup to
plex_data_dir="/var/lib/plex/" # Plex data directory. Default to Arch's
in_backup_file="/path/to/backup_dirs.txt" # File with the folders and files to sync. Example in backup_dirs.txt (leave - ** unless you want ALL your disk synced, which would be really dumb)
local_backup_dir="/mnt/reallybig8GBexternaldrive/" # Where to backup all your files locally. Yeah, dumb I guess

backup=$local_backup_dir$backup_name

# Backup Plex data
sudo tar -czf $local_backup_dir\plex-backup.tar.gz $plex_data_dir

# Sync other files with rclone (including symbolic links)
rclone sync / $local_backup_dir --filter-from=$in_backup_file --links

# Compress and encrypt everything using tar and gpg
sudo tar --exclude="*.gpg" -czf - $local_backup_dir | gpg -c --passphrase-file=$serious_password --cipher-algo aes256 --batch --yes > $backup.tar.gz.gpg

# Upload it to a Send instance. The URL will be saved to a text file
ffsend upload -h $send_instance -yqI --force --password=$dumb_password --downloads 5 --expiry-time 7d $backup.tar.gz.gpg > $backup.txt

# Attach the date of the backup to the file
date +'%d/%m/%y - %H:%M' >> $backup.txt

# Remove kinda useless stuff. If you want
rm $backup.tar.gz.gpg