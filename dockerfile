ARG MSSQLYear 2019

FROM mcr.microsoft.com/mssql/server:${MSSQLYear}-latest

ARG AdventureWorksYear 2019
ARG AdventureWorksType ""

ENV MSSQL_PID Express
ENV SA_PASSWORD !demo54321
ENV ACCEPT_EULA Y

USER root

# Add microsoft SQL binaries to PATH
ENV PATH="/opt/mssql-tools/bin/:$PATH"

# Upgrade packages and cleanup unused dependencies
RUN DEBIAN_FRONTEND="noninteractive"; \
    TZ="Europe/Amsterdam"; \
    apt-get update -qq && \ 
    apt-get full-upgrade -qq --yes && \
    apt-get dist-upgrade -qq --yes && \
    apt-get autoremove -qq --yes && \
    rm -rf /var/lib/apt/lists/*

#! Forces conflicts of different python versions of Ubuntu 18.04 / 20.04
# # Install mssql-cli
# # See: https://docs.microsoft.com/de-de/sql/tools/mssql-cli?view=sql-server-ver15#install-mssql-cli
# # Import the public repository GPG keys and register the Microsoft Ubuntu repository, then install mssql-cli.
# RUN DEBIAN_FRONTEND="noninteractive"; \
#     TZ="Europe/Amsterdam"; \
#     apt-get update -qq && \ 
#     apt-get install -qq --yes \
#         curl \
#         software-properties-common \
#         apt-transport-https && \
#     curl --silent https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
#     apt-add-repository https://packages.microsoft.com/ubuntu/$(grep -o -P '(?<=Ubuntu\s)\d*\.\d*(?=\.\d)' /etc/issue)/prod && \
#     apt-get update -qq && \
#     apt-get install -qq --yes \
#         mssql-cli && \
#     apt-get install -f && \
#     rm -rf /var/lib/apt/lists/*

# # Opt out of mssql-cli telemetry
# # See: https://github.com/dbcli/mssql-cli/blob/master/doc/telemetry_guide.md
# ENV MSSQL_CLI_TELEMETRY_OPTOUT True

#! This doesn't work with versions prior MSSQL-Server 2019
# RUN id -u mssql $> /dev/null || useradd mssql
# USER mssql

# Download and import AdventureWork database to container.
WORKDIR /init-databases
RUN wget -q "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks${AdventureWorksType}${AdventureWorksYear}.bak"

# Install dependencies of entrypoint.sh
RUN DEBIAN_FRONTEND="noninteractive"; \
    TZ="Europe/Amsterdam"; \
    apt-get update -qq && \ 
    apt-get install -qq --yes \
        netcat && \
    rm -rf /var/lib/apt/lists/*

COPY [ "entrypoint.sh", "/"]
RUN chmod +x /entrypoint.sh

EXPOSE 1433
CMD /entrypoint.sh -h localhost -u sa -p ${SA_PASSWORD}
