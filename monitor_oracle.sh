#!/bin/bash

# Set the default logfile location
LOG_FILE=monitor_oracle.log

# Source the oracle environment. This you may have to adapt to your environment
. /home/oracle/.bash_profile

# Check for flag --hl which will only use default values and skip the user prompts so it can be used in scripts and cronjobs
if [ "$1" == "--hl" ]
then
    echo "Using default values"
else
    # Prompt for the database name
    echo "Enter the database name or press enter to use the default (orcl):"
    read DB_NAME

    # If the user entered a database name, use that, otherwise use the default
    if [ -z "$DB_NAME" ]
    then
        DB_NAME=orcl
    fi

    # Prompt for the database user
    echo "Enter the database user or press enter to use the default (system):"
    read DB_USER

    # If the user entered a database user, use that, otherwise use the default
    if [ -z "$DB_USER" ]
    then
        DB_USER=system
    fi

    # Prompt for the database password
    echo "Enter the database password or press enter to use the default (oracle):"
    read DB_PASS

    # If the user entered a database password, use that, otherwise use the default
    if [ -z "$DB_PASS" ]
    then
        DB_PASS=oracle
    fi

    # Prompt for the database port
    echo "Enter the database port or press enter to use the default (1521):"
    read DB_PORT

    # If the user entered a database port, use that, otherwise use the default
    if [ -z "$DB_PORT" ]
    then
        DB_PORT=1521
    fi

    # Prompt for the database host
    echo "Enter the database host or press enter to use the default (localhost):"
    read DB_HOST

    # If the user entered a database host, use that, otherwise use the default
    if [ -z "$DB_HOST" ]
    then
        DB_HOST=localhost
    fi

    
fi


# Prompt for an output filename and path as an alternative to the default.

echo "Enter the logfile name and path or press enter to use the default ($LOG_FILE):"
read LOG_FILE

# If the user entered a filename, use that, otherwise use the default
if [ -z "$LOG_FILE" ]
then
    LOG_FILE=monitor_oracle.log
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
free >> $LOG_FILE
echo "" >> $LOG_FILE