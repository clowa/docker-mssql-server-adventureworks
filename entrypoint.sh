#!/bin/bash

function init-databases () {
    # Wait to be sure MSSQL server came up
    while ! netcat -z localhost ${MSSQL_TCP_PORT:-1433]} 2> /dev/null
    do
        sleep 2
    done
    
    for restoreFile in /init-databases/*.bak
    do
        fileName=${restoreFile##*/}
        base=${fileName%.bak}
        echo "Importing database $base ..."
        /opt/mssql-tools/bin/sqlcmd -S $1 -U $2 -P $3 -Q "RESTORE DATABASE [$base] FROM  DISK = '$restoreFile' WITH FILE = 1,  MOVE '$base' TO N'/var/opt/mssql/data/${base}.mdf',  MOVE '${base}_log' TO N'/var/opt/mssql/data/${base}_log.ldf', NOUNLOAD, REPLACE, STATS = 5" || exit 1
        rm -rf $restoreFile
    done
}

while getopts h:u:p: flag
do
    case "${flag}" in
        h) HOSTNAME=${OPTARG};;
        u) USERNAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
    esac
done

init-databases $HOSTNAME $USERNAME $PASSWORD & /opt/mssql/bin/sqlservr