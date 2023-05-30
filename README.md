# Oracle logging PGA Memory and how it's affected by inactive connections

## Summary
This collection of scripts is inspired by a problem occuring in one of my consulting gigs, where we encountered a problem with PGA-memory in Oracle database servers being clogged up by inactive connections.

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

- A script which outputs the total PGA allocation, the PGA usage of inactive sessions and the total amount of inactive sessions to a logfile. The logfile size can be limited.
- A script which can be used to mail the logfile regularly and purge the logfile to ensure it doesn't clog up the system 
- A suggestion for a crontab entry

Created by Sebastian Varga (Twitter: https://twitter.com/sebvarga)