#!/bin/bash
set -e

# Validate required environment variables
: ${BACKUP_DIR:?"ERROR: BACKUP_DIR is not set"}
: ${PGHOST:?"ERROR: PGHOST is not set"}
: ${PGUSER:?"ERROR: PGUSER is not set"}
: ${PGDATABASE:?"ERROR: PGDATABASE is not set"}
: ${PGPASSWORD:?"ERROR: PGPASSWORD is not set"}
: ${RETENTION_DAYS:?"ERROR: RETENTION_DAYS is not set"}

NOW=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILE=$BACKUP_DIR/backup_$NOW.sql.gz
LOG_FILE=$BACKUP_DIR/backup_$NOW.log

echo "Starting backup: $NOW" > $LOG_FILE
echo "Database: $PGDATABASE on $PGHOST" >> $LOG_FILE

# Perform backup
if pg_dump -h $PGHOST -U $PGUSER $PGDATABASE | gzip > $BACKUP_FILE 2>> $LOG_FILE; then
    # Verify backup file was created and has content
    if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "Backup completed successfully: $BACKUP_FILE (Size: $BACKUP_SIZE)" >> $LOG_FILE
        echo "$(date +'%Y-%m-%d %H:%M:%S') - SUCCESS: Backup created successfully" >> $BACKUP_DIR/backup_summary.log
    else
        echo "ERROR: Backup file is empty or was not created" >> $LOG_FILE
        echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: Backup file empty or missing" >> $BACKUP_DIR/backup_summary.log
        exit 1
    fi
else
    echo "Backup failed! Check log for details." >> $LOG_FILE
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: pg_dump failed" >> $BACKUP_DIR/backup_summary.log
    exit 1
fi

# Delete old backups and logs (older than RETENTION_DAYS)
DELETED_COUNT=$(find $BACKUP_DIR -type f -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS | wc -l)
if [ $DELETED_COUNT -gt 0 ]; then
    echo "Deleting $DELETED_COUNT old backup(s) older than $RETENTION_DAYS days" >> $LOG_FILE
    find $BACKUP_DIR -type f -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    find $BACKUP_DIR -type f -name "backup_*.log" -mtime +$RETENTION_DAYS -delete
fi

echo "Backup process completed at $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE

