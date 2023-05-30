#!/bin/bash

# Set the default logfile location
LOG_FILE=monitor_oracle.log

# Set one or multiple e-mail addresses to send alerts to

EMAIL_ADDRESS=""

# Source the oracle environment. This you may have to adapt to your environment
. /home/oracle/.bash_profile

# First check if the required environment variables are set.If one of the requirede variable is not set, the script will exit and send a notification mail to the specified e-mail address.

if [ -z "$ORACLE_HOME" ]
then
    echo "ORACLE_HOME is not set. Please set the ORACLE_HOME environment variable." >> $LOG_FILE
    echo "Script will exit." >> $LOG_FILE
    echo "---- $(date) ----" >> $LOG_FILE
    mail -s "ORACLE_HOME is not set" $EMAIL_ADDRESS < $LOG_FILE
    exit
fi

if [ -z "$ORACLE_SID" ]
then
    echo "ORACLE_SID is not set. Please set the ORACLE_SID environment variable." >> $LOG_FILE
    echo "Script will exit." >> $LOG_FILE
    echo "---- $(date) ----" >> $LOG_FILE
    mail -s "ORACLE_SID is not set" $EMAIL_ADDRESS < $LOG_FILE
    exit
fi

# Print the current date and time
echo "---- $(date) ----" >> $LOG_FILE

# Print the current memory usage per inactive process
# Uncomment the section below, if you want a per process breakdown
# Careful, this can be a lot of data, don't run this in a cronjob

# sqlplus -s / as sysdba <<EOF >> $LOG_FILE
# set lines 200
# set pages 200
# col sid format 9999
# col username format a10
# col osuser format a10
# col status format a10
# col module format a10
# col program format a30
# select s.sid, s.username, s.osuser, s.status, s.module, p.program, 
# round((p.value/1024/1024),2) "PGA_MB" 
# from v\$session s, v\$sesstat t, v\$statname n, v\$process p 
# where s.sid = t.sid and s.paddr = p.addr and t.statistic# = n.statistic# 
# and n.name = 'session pga memory' and s.status = 'INACTIVE' order by "PGA_MB" desc;
# exit;
# EOF

# End of per process breakdown
# **********


# Use the below section for a total memory usage overview. You can run as cronjob for continuous monitoring

# Print the total amount of PGA memory allocated
sqlplus -s / as sysdba <<EOF >> $LOG_FILE
SELECT name, ROUND(value/(1024*1024*1024),2) as value_in_GB FROM v\$pgastat WHERE name IN ('total PGA allocated', 'total PGA used by SQL workareas');
EOF

# Print the total amount of inactive sessions
sqlplus -s / as sysdba <<EOF >> $LOG_FILE
SELECT COUNT(1) FROM gv\$session WHERE status = 'INACTIVE';
EOF

# Print the current memory usage for all inactive process combined
sqlplus -s / as sysdba <<EOF >> $LOG_FILE
SELECT SUM(value/(1024*1024*1024)) as "Inactive_PGA_GB"
FROM v\$sesstat t, v\$statname n, v\$session s 
WHERE t.STATISTIC# = n.STATISTIC# 
AND n.name = 'session pga memory' 
AND s.sid = t.sid
AND s.status = 'INACTIVE';
EOF

# Print the Memory Size of the server
echo "---- Memory Size ----" >> $LOG_FILE
free -h >> $LOG_FILE
echo "" >> $LOG_FILE