# Day 19 Challenge: Real-World Server Automation

Overview
Today was all about combining the scripting fundamentals I’ve learned to solve actual production problems. I built a log rotation script to prevent disks from filling up, a backup script to protect critical data, and an overarching maintenance script. Finally, I learned how to automate all of them using Linux's time-based job scheduler: cron.

# Task 1: Log Rotation Script

Script: log_rotate.sh

This script takes a directory path as an argument, compresses .log files older than 7 days, and deletes .gz files older than 30 days to free up storage space.

Bash

#!/bin/bash

#This is for log rotation

#Important: it takes a path of directory as an argument
set -eou pipefail


check_for_argument() {

    echo "Please provide the path as an argument of log directory"
    exit 1
}

if [ $# -eq 0 ] ; then

    check_for_argument
fi

log_dir_path=$1

compress_log() {

    # command used to find and compress files older than 7 days
    find $log_dir_path -name "*.log" -type f -mtime +7 -exec gzip {} \;
    echo "Total files compressed are $(find $log_dir_path -name "*.log.gz" -type f | wc -l)"
}

delete_gz() {

    echo "Total files deleted are $(find $log_dir_path -name "*.gz" -type f -mtime +30 | wc -l)"
    # command used to delete the .gz files
    find $log_dir_path -name "*.gz" -type f -mtime +30 -delete
}

compress_log

delete_gz

# Task 2: Server Backup Script

Script: backup.sh

This script takes a source and destination path, creates a compressed timestamped archive, verifies its creation, prints the size, and cleans up backups older than 14 days.

Bash

#!/bin/bash

directory_path() {

    echo "Please enter the source and destination path in the exact flow"
    exit 1
}

if [ $# -lt 2 ] ; then

    directory_path
fi

source_path="$1"

destination_path="$2"

#Check if the source exists

if [ ! -d "$source_path" ]; then 

    echo "ERROR: Source directory '$source_path' does not exist."
    exit 1
fi

archive() {

    # Define the full path for the output file
    local archive_name="$destination_path/backup-$(date +%Y-%m-%d).tar.gz"
    
    # Run tar with the output file first, then use -C to go to source, then . for content
    tar -czvf "$archive_name" -C "$source_path" .
    
    if [ $? -eq 0 ] ; then
        echo "Archive file created successfully: $archive_name"
        # Print file size as requested
        echo "Archive size is: $(du -sh "$archive_name" | cut -f1)"
    fi

    echo "Archive files are: "
    echo "$(find $destination_path -name "*.tar.gz" -type f)"
}

delete_old_backups() {

    find $destination_path -name "*.tar.gz" -type f -mtime +14 -delete
}

archive

delete_old_backups

# Task 3 & 4: Scheduled Maintenance & Crontab

Script: maintenance.sh

A master script that calls both the backup and log rotation scripts, logging every action with a timestamp.

Bash
#!/bin/bash

#Configuration

LOG_FILE="/var/log/maintenance.log"

# Ensure your scripts are in your PATH or use absolute paths

LOG_ROTATE_SCRIPT="/home/sachin/scripts/log_rotate.sh"

BACKUP_SCRIPT="/home/sachin/scripts/backup.sh"

# Function to log messages with timestamps

log_message() {

    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "Starting scheduled maintenance."

#Call Log Rotation

log_message "Running log rotation..."

bash "$LOG_ROTATE_SCRIPT" /var/log/myapp >> "$LOG_FILE" 2>&1

#Call Backup

log_message "Running backup..."

bash "$BACKUP_SCRIPT" /home/user/data /backups >> "$LOG_FILE" 2>&1

log_message "Maintenance completed successfully."



# Crontab Entries

I practiced writing the cron syntax to schedule these jobs automatically. (Viewed via crontab -l, edited via crontab -e).

Bash

#Run log_rotate.sh every day at 2 AM

0 2 * * * /home/sachin/scripts/log_rotate.sh /var/log/myapp

#Run backup.sh every Sunday at 3 AM

0 3 * * 0 /home/sachin/scripts/backup.sh /home/user/data /backups

#Run a health check script every 5 minutes

*/5 * * * * /home/sachin/scripts/health_check.sh

#Run the combined maintenance script daily at 1 AM

0 1 * * * /home/sachin/scripts/maintenance.sh

# What I Learned

The Power of find and -exec: I learned that the find command is incredibly versatile. 
Combining -mtime +7 with -exec gzip {} \; allowed me to find old files and immediately run a compression command on each of them in a single line.

Mastering the Tarball: Creating archives with tar is a staple in Linux. Using the -C flag to change into the source directory before zipping prevents the archive from saving the absolute folder path structure (like /home/user/data/), making extractions much cleaner.

Cron Syntax: The five stars of cron (* * * * * representing Minute, Hour, Day of Month, Month, Day of Week) look intimidating at first, but they provide absolute control over exactly when an automation triggers. Appending >> "$LOG_FILE" 2>&1 ensures that both standard output and errors are captured while I am asleep!
