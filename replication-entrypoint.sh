#!/bin/bash
set -eo pipefail

cat > /etc/mysql/mysql.conf.d/repl.cnf << EOF
[mysqld]
log-bin=mysql-bin
relay-log=mysql-relay
#bind-address=0.0.0.0
#skip-name-resolve
EOF

#Get the user options for Mysql
env | grep MYSQL_OPTION > /tmp/mysql_options
/usr/local/bin/mysql_options.py 

# If there is a linked master use linked container information
if [ -n "$MASTER_PORT_3306_TCP_ADDR" ]; then
  export MASTER_HOST=$MASTER_PORT_3306_TCP_ADDR
  export MASTER_PORT=$MASTER_PORT_3306_TCP_PORT
fi
echo "Master: ${MASTER_HOST}"

if [ -z ${MYSQL_ROOT_PASSWORD} ]; then
  ROOT_PASSWORD=""
else
  ROOT_PASSWORD="-p ${MYSQL_ROOT_PASSWORD}"
fi

if [ -z "$MASTER_HOST" ]; then
  export SERVER_ID=1
  cp -v /init-master.sh /docker-entrypoint-initdb.d/
else
  # TODO: make server-id discoverable
  DATE=`date +%s`
  export SERVER_ID=`echo $(( ( ${DATE} % 50 ) + 2 ))` #Generate a random number for the ID
  echo ${SERVER_ID}
  cp -v /init-slave.sh /docker-entrypoint-initdb.d/
  cat > /etc/mysql/mysql.conf.d/repl-slave.cnf << EOF
[mysqld]
log-slave-updates
master-info-repository=TABLE
relay-log-info-repository=TABLE
relay-log-recovery=1
EOF
fi
cat > /etc/mysql/mysql.conf.d/server-id.cnf << EOF
[mysqld]
server-id=$SERVER_ID
EOF

#Set Backups
if [ ! -z ${MYSQL_BACKUP} ]; then
  if [ ! -d /var/backups/ ]; then
    mkdir -p /var/backups/
  fi
  echo "0 * * * * /usr/local/bin/mysql_backup.sh"  | crontab -u root -
  env | grep mysql_backup_db > /tmp/mysql_backup
  touch /etc/databases_backup
  while read p; do
    echo $p | cut -d '=' -f 2 >> /etc/databases_backup
  done < /tmp/mysql_backup
fi

exec docker-entrypoint.sh "$@"