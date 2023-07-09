---
title: "My RSYNC Backup Solution"
date: 2022-09-05
image: "cover.png"
categories:
- Server Solutions
- Scripts
keywords:
- rsync
- backup
- systemd timers
---
I wanted to implement a simple backup solution for my 8TB RAID0 setup. The RAID is mounted at /mnt/storage, and the backup drive is a single 8TB drive mounted at /mnt/backup. I wanted to create a back up solution that would run every night at 1:00 am and simply copy the RAID to the single drive. I decided to use systemd-timers to schedule the backup and use RSYNC to perform the task.

First, I created a service in /etc/systemd/system/ called scheduled-backup.service.
```
sudo nano /etc/systemd/system/scheduled-backup.service
```
In this file, I write:
```
[Unit]
Description=rsync backup

[Service]
ExecStart=sudo rsync -aAXv --log-file=/home/USER/rsync-storage.log --delete-after /mnt/storage/ /mnt/backup/storage/
Type=oneshot
```
The rsync command archives while preserving permissions, ACLs, and extended attributes. Once the new files are received by the the backup drive, rsync will delete the old copies of the files. A log is written in the HOME directory.

After I created the service, I then create the timer.
```
sudo nano /etc/systemd/system/scheduled-backup.timer
```
In this file, I write:
```
[Unit]
Description=rsync backup

[Timer]
OnCalendar=01:00:00
Persistent=true

[Install]
WantedBy=timers.target
```
This timer tells systemd to run the service at 1:00 am every day. The "Persistent=true" tells the timer to run this immediately if the last scheduled time was missed. Then I enable and start the timer.
```
sudo systemctl enable scheduled-backup.timer
sudo systemctl start scheduled-backup.timer
```
Finally, I reload the systemd daemon.
```
sudo systemctl daemon-reload
```
## UPDATE:

After using this setup for about six months now, I decided to break up the log files rather than having one big log. I also moved the log to /var/log/rsync directory.

Because I needed to use a variable in the rsync command, I took the command out of the schedule-backup.service file and made a bash script to run the command. In the schedule-backup.service file, I simply call that script.

The service file now looks like this:
```
...
ExecStart=sudo /usr/bin/scheduled-backup
...
```
And, the scheduled-backup script looks like this:
```
#!/bin/bash

rsync -aAXv --log-file="/var/log/rsync/$(date +%F)-rsync-storage.log" --delete-after /mnt/storage/ /mnt/backup/storage/

rsync -aAXvzP --log-file="/var/log/rsync/$(date +%F)-rsync-home.log" --exclude-from='/home/USER/bu-ignore-list.txt' --delete-after /home/USER/ /mnt/backup/home/
```
In addition to adding a backup for the home drive, I created an backup ignore list which is a plain text file that lists directories that I don't want included in the backup, like .cache. The log files are now broken up by the date the log is made. I accomplished this by using the date command with the %F flag.
