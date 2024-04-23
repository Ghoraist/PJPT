#!/bin/bash

################################################################
##
##   Site Backup To Amazon S3
##   Written By: YONG MOOK KIM
##   https://www.mkyong.com/linux/how-to-zip-unzip-tar-in-unix-linux/
##   https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html
##   https://mkyong.com/linux/how-to-backup-a-website-to-amazon-s3-using-shell-script/
##
##   $crontab -e
##   Weekly website backup, at 01:30 on Sunday
##   30 1 * * 0 /home/mkyong/script/backup-site.sh > /dev/null 2>&1
################################################################

NOW=$(date +"%Y-%m-%d")
NOW_TIME=$(date +"%Y-%m-%d %T %p")
NOW_MONTH=$(date +"%Y-%m")

BACKUP_DIR="/home/www/backup/$NOW_MONTH"
BACKUP_FILENAME="site-$NOW.tar.gz"
BACKUP_FULL_PATH="$BACKUP_DIR/$BACKUP_FILENAME"

AMAZON_S3_BUCKET="s3://www/backup/site/$NOW_MONTH/"
AMAZON_S3_BIN="/home/www/.local/bin/aws"

# put the files and folder path here for backup
CONF_FOLDERS_TO_BACKUP=("/etc/nginx/nginx.conf" "/etc/nginx/conf.d" "/path.to/file" "/path.to/folder")
SITE_FOLDERS_TO_BACKUP=("/var/www/wordpress/" "/var/www/others")

#################################################################

mkdir -p ${BACKUP_DIR}

backup_files(){
        tar -czf ${BACKUP_DIR}/${BACKUP_FILENAME} ${CONF_FOLDERS_TO_BACKUP[@]} ${SITE_FOLDERS_TO_BACKUP[@]}
}

upload_s3(){
        ${AMAZON_S3_BIN} s3 cp ${BACKUP_FULL_PATH} ${AMAZON_S3_BUCKET}
}

backup_files
upload_s3

# this is optional, we use mailgun to send email for the status update
if [ $? -eq 0 ]; then
        # if success, send out an email
        curl -s --user "api:keyABCD123" \
                https://api.mailgun.net/v3/mg.www.com/messages \
                -F from="backup job <backup@www.com>" \
                -F to=user@yourdomain.com \
                -F subject="Backup Successful (Site) - $NOW" \
                -F text="File $BACKUP_FULL_PATH is backup to $AMAZON_S3_BUCKET, time:$NOW_TIME"
else
        # if failed, send out an email
        curl -s --user "api:keyABCD123" \
                https://api.mailgun.net/v3/mg.www.com/messages \
                -F from="backup job <backup@yourdomain.com>" \
                -F to=user@yourdomain.com \
                -F subject="Backup Failed! (Site) - $NOW" \
                -F text="Unable to backup!? Please check the server log!"
fi;

#if [ $? -eq 0 ]; then
#  echo "Backup is done! ${NOW_TIME}" | mail -s "Backup Successful (Site) - ${NOW}" -r cron admin@mkyong.com
#else
#  echo "Backup is failed! ${NOW_TIME}" | mail -s "Backup Failed (Site) ${NOW}" -r cron admin@mkyong.com
#fi;

