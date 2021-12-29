#!/usr/bin/env bash
set -e

while getopts u:p:h:d:f: flag
do
    case "${flag}" in
        u) USERNAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
        h) HOSTNAME=${OPTARG};;
        d) DATABASE=${OPTARG};;
        f) BACKUPFILE=${OPTARG};;
    esac
done

echo "USERNAME: $USERNAME"
echo "PASSWORD: $PASSWORD"
echo "HOSTNAME: $HOSTNAME"
echo "DATABASE: $DATABASE"
echo "BACKUPFILE: $BACKUPFILE"
shift 10
# echo "\$@: $@"

exec /opt/mssql/bin/sqlservr

sqlcmd -S $HOSTNAME -U $USERNAME -P $PASSWORD -Q "RESTORE DATABASE [Database] FROM  DISK = N'$BACKUPFILE' WITH FILE = 1,  MOVE N'$DATABASE' TO N'/var/opt/mssql/data/${DATABASE}.mdf',  MOVE N'$DATABASE_log' TO N'/var/opt/mssql/data/${DATABASE}_log.ldf', NOUNLOAD, REPLACE, STATS = 5" || exit 1

