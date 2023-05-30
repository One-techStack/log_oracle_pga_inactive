# Oracle logging PGA Memory and how it's affected by inactive connections

## Summary
This collection of scripts is inspired by a problem with PGA-memory in Oracle database servers being clogged up by inactive connections.

Inactive connections are held in the PGA-Memory of Oracle servers and each usually only take up a few MBytes of RAM. However, if you have thousands of connections and do not properly close them, they may up being kept on the record of the server.

## Background
### Oracle Memory Architecture: SGA, PGA, and Inactive Connections

#### System Global Area (SGA)

The System Global Area (SGA) is a shared memory segment in Oracle Database that contains data and control information for one Oracle Database instance. The SGA is used to store incoming data and internal control information that is shared by the database processes and by Oracle background processes. Components of SGA include the database buffer cache, shared pool, and log buffer, among others.

#### Program Global Area (PGA)

The Program Global Area (PGA) is a memory region that contains data and control information for a server process. It's non-shared memory created by Oracle Database when a server process is started. The information in this area is process-specific, which means it's only available to the server process itself. The PGA includes sort area, session information, and the stack space. The size of PGA affects the performance of the Oracle server.

#### Inactive Connections and Memory Consumption

Oracle connections, whether active or inactive, consume resources. An inactive connection still holds session-specific details in the PGA. Thus, a high number of inactive connections can lead to the PGA filling up, which might impact the performance of the database server or even prevent new connections if the memory is completely consumed. 

It's crucial for applications to properly manage their database connections, closing them when no longer required. Otherwise, the server might be left with a large number of inactive connections, each consuming valuable resources and potentially leading to performance issues. It's possible to set up configurations, either server-side or client-side, to better handle idle timeouts and ensure unused connections are properly released. 

Remember, increasing physical memory may provide temporary relief, but it's not a long-term solution if the cause of the problem is not properly addressed. Proper management of the connections and optimal configuration of the SGA and PGA parameters are key to efficient database performance.

## What this Repository (will) contain(s)

\- ```monitor_oracle.sh```:
An interactive shell-script which outputs the total PGA allocation, the PGA usage of inactive sessions and the total amount of inactive sessions to a logfile. Do not use in cronjob

\- ```logrotate_monitor.sh```:
The logroatate script

\- ```example_crontab```:
An example on how you can set your cron jobs to run the script (default every 5 minutes) and when to rotate the log file (when 100MByte)

## Usage

Put the script 'monitor_oracle.sh' in a folder of your choice. To start, you can just put it in the home-directory. Make sure, you have the appropriate database access rights.

Make the scripts are executeable. In the folder where the script is located, run:
```chmod +x monitor_oracle.sh```
```chmod +x logrotate_monitor.sh```


### How to configure crontab:
Cron jobs for individual users are stored in the cron daemon's spool area, which is typically a directory under `/var/spool/cron` or `/var/spool/cron/crontabs` on most Unix-like systems.

The files in these directories are named after the users to whom they belong, and the permissions are set so that only the user and root can read or write to their respective file.

The `crontab -e` command opens the current user's cron file in the default text editor for modification. Once the changes are saved and the editor is exited, the cron daemon automatically reloads the file and applies any changes.

Remember, these files should not be edited directly, as the changes may not be picked up by the cron daemon. Always use the `crontab` command to interact with these files.

System-wide cron jobs are typically stored in `/etc/crontab` or under the `/etc/cron.d/` directory. These files can only be edited by the root user and are used for system tasks. Users can also place scripts in the `/etc/cron.hourly`, `/etc/cron.daily`, `/etc/cron.weekly`, and `/etc/cron.monthly` directories to have them automatically run at those intervals.

Each of these directories is checked by the cron daemon, and any scripts within them are executed at the specified intervals.



Created by Sebastian Varga (Twitter: https://twitter.com/sebvarga)