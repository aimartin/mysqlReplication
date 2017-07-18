#!/bin/bash
#
# MySQL Backup Script
#  Dumps mysql databases to a file for another backup tool to pick up.
#
# MySQL code:
# GRANT SELECT, RELOAD, LOCK TABLES ON *.* TO 'user'@'localhost'
# IDENTIFIED BY 'password';
# FLUSH PRIVILEGES;
#
##### START CONFIG ###################################################

USER=${REPLICATION_USER}
PASS=${REPLICATION_PASSWORD}
DIR=/var/backups/
ROTATE=2

PREFIX=mysql_backup_

EVENTS="--ignore-table=mysql.event"


##### STOP CONFIG ####################################################
PATH=/usr/bin:/usr/sbin:/bin:/sbin



set -o pipefail

cleanup()
{
    find "${DIR}/" -maxdepth 1 -type f -name "${PREFIX}*.sql*" -mtime +${ROTATE} -print0 | xargs -0 -r rm -f
}

while read database; do
mysqldump -u${USER} -p${PASS} --opt --flush-logs --single-transaction \
    ${EVENTS} \
 ${database}| bzcat -zc > ${DIR}/${PREFIX}${database}_`date +%Y%m%d-%H%M%S`_`hostname`.sql.bz2
done < /etc/databases_backup

if [ $? -eq 0 ] ; then
    cleanup
fi