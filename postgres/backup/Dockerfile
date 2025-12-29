FROM postgres:18

# Install cron and clean up apt cache to reduce image size
RUN apt-get update && \
    apt-get install -y cron && \
    rm -rf /var/lib/apt/lists/*

# Copy backup script and crontab
COPY backup.sh /usr/local/bin/backup.sh
COPY crontab-root /etc/cron.d/backup-cron

# Set proper permissions
RUN chmod +x /usr/local/bin/backup.sh && \
    chmod 0644 /etc/cron.d/backup-cron && \
    crontab /etc/cron.d/backup-cron && \
    touch /var/log/cron.log

# Start cron and tail log
CMD ["bash", "-c", "echo 'Backup container started. Cron is running...' && cron && tail -f /var/log/cron.log"]
