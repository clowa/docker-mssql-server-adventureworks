ARG MSSQLYear=2019

FROM mcr.microsoft.com/mssql/server:${MSSQLYear}-latest

ARG AdventureWorksYear=2019
ARG AdventureWorksType=""

ENV MSSQL_PID=Developer
ENV SA_PASSWORD=!demo54321
ENV ACCEPT_EULA=Y

USER root

# Upgrade packages and cleanup unused dependencies
RUN apt-get update -qq && \ 
    apt-get full-upgrade -qq --yes && \
    apt-get dist-upgrade -qq --yes && \
    apt-get autoremove -qq --yes && \
    rm -rf /var/lib/apt/lists/*

# Install mssql-cli
# See: https://docs.microsoft.com/de-de/sql/tools/mssql-cli?view=sql-server-ver15#install-mssql-cli

# Import the public repository GPG keys and register the Microsoft Ubuntu repository, then install mssql-cli, sqlcmd and bcp (Bulk Copy Program).
RUN apt-get update -qq && \
    apt-get install -qq --yes \
        curl \
        software-properties-common \
        apt-transport-https && \
    curl --silent https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-add-repository https://packages.microsoft.com/ubuntu/$(grep -o -P '(?<=Ubuntu\s)\d*\.\d*(?=\.\d)' /etc/issue)/prod && \
    apt-get update -qq && \
    apt-get install -qq --yes \
        mssql-cli \
        mssql-tools \
        unixodbc-dev && \
    apt-get install -f && \
    rm -rf /var/lib/apt/lists/*
# Add microsoft SQL binaries to PATH
ENV PATH="/opt/mssql-tools/bin/:$PATH"

#! This doesn't work with versions prior MSSQL-Server 2019
# RUN id -u mssql $> /dev/null || useradd mssql
# USER mssql

# Download and import AdventureWork database to container.
WORKDIR /database-backups
RUN wget -q "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks${AdventureWorksType}${AdventureWorksYear}.bak"

RUN (/opt/mssql/bin/sqlservr --accept-eula & ) | grep -q "Starting database restore" && -Q "RESTORE DATABASE [AdventureWorks${AdventureWorksType}${AdventureWorksYear}] FROM  DISK = N'/database-backups/AdventureWorks${AdventureWorksType}${AdventureWorksYear}.bak' WITH FILE = 1,  MOVE N'AdventureWorks${AdventureWorksType}${AdventureWorksYear}' TO N'/var/opt/mssql/data/AdventureWorks${AdventureWorksType}${AdventureWorksYear}.mdf',  MOVE N'AdventureWorks${AdventureWorksType}${AdventureWorksYear}_log' TO N'/var/opt/mssql/data/AdventureWorks${AdventureWorksType}${AdventureWorksYear_log}.ldf', NOUNLOAD, REPLACE, STATS = 5"
# HEALTHCHECK --interval=10s --timeout=1m\
#   CMD sqlcmd -S . -U sa -P $SA_PASSWORD -Q "RESTORE DATABASE [AdventureWorks$AdventureWorksType$AdventureWorksYear] FROM  DISK = N'/database-backups/AdventureWorks$AdventureWorksType$AdventureWorksYear.bak' WITH FILE = 1,  MOVE N'AdventureWorks$AdventureWorksType$AdventureWorksYear' TO N'/var/opt/mssql/data/AdventureWorks$AdventureWorksType$AdventureWorksYear.mdf',  MOVE N'AdventureWorks$AdventureWorksType$AdventureWorksYear_log' TO N'/var/opt/mssql/data/AdventureWorks$AdventureWorksType$AdventureWorksYear_log.ldf', NOUNLOAD, REPLACE, STATS = 5" || exit 1

# sqlcmd -S . -U SA -P ${SA_PASSWORD} -Q "RESTORE DATABASE [demodb] FROM DISK = N'/var/opt/mssql/data/demodb.bak' WITH FILE = 1, NOUNLOAD, REPLACE, NORECOVERY, STATS = 5"

