mysqldump -h 192.168.0.11 -P 13306 -u root -pWeAreSuperman tardis_stage > 1.sql
mysql -h 192.168.0.11 -P 13306 -u root -pWeAreSuperman tardis_stage < 1.sql

mysqldump --user=root --all-databases --flush-privileges --single-transaction \
--master-data=1 --flush-logs --triggers --routines --events \
--hex-blob > $BACKUP_DIR/full_dump_$BACKUP_TIMESTAMP.sql