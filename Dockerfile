FROM mysql:5.7
ENV REPLICATION_USER replication
ENV REPLICATION_PASSWORD replication_pass
RUN apt-get update && apt-get install -y vim python
COPY replication-entrypoint.sh /usr/local/bin/
COPY init-slave.sh /
copy init-master.sh /
copy mysql_options.py /usr/local/bin/
ENTRYPOINT ["replication-entrypoint.sh"]
CMD ["mysqld"]