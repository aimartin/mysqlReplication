Mysql Auto-Replication Docker Container

This container will build up a Mysql Server configured and ready to work as a master, and will also build up as many slaves as you want.

Configuration Options

MYSQL_ROOT_PASSWORD: Choose a Root Password
REPLICATION_PASSWORD: Choose the Replication Password
MYSQL_BACKUP: If not empty, Mysql Backups will be enabled and stored in /var/backups/
MYSQL_BACKUP_DB_XXXX: Name of the Database that will be backed up, you can add as many as you need

Example:
MYSQL_BACKUP_DB_testingA=testing1
MYSQL_BACKUP_DB_testingB=testing2

This will create an *hourly* of databases testing1 and testing2 


MYSQL_OPTION_XXXXX
You can add as many Mysql Options as you want, the init script will remove MYSQL_OPTION_ from the name of the option and add it to the Mysql config.

Example:
MYSQL_OPTION_innodb_buffer_pool_size=12G
MYSQL_OPTION_innodb_file_per_table=1

This will create a mysql.conf file adding the following options
innodb_buffer_pool_size=12G
innodb_file_per_table=1

Notes:
Be sure you name the MYSQL_BACKUP_DB_XXXX options with different names!
Be sure you mount the Backup folder outside the box!!