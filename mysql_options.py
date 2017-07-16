#!/usr/bin/python

F = open("/tmp/mysql_options","r") 
OPTION = open("/etc/mysql/mysql.conf.d/mysql_options.cnf","w") 
OPTION.write("[mysqld]")
for line in F:
	if line != "" and line.find("MASTER_ENV") == -1: 
		OPTION.write(line.replace('MYSQL_OPTION_',''))