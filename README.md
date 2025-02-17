> [!NOTE]
> This repository has been archvied on 17.02.2025

# Overview

Just a little docker repo to build a MSSQL-server image with the example database [AdventureWorks](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/adventure-works) preinstalled.

You can find the image on [Docker Hub](https://hub.docker.com/r/clowa/mssql-server-adventureworks).

## Build script usage

```powershell
build.ps1 [[-DockerTag] <string>] [[-Platform] <string[]>] [[-Years] <string[]>] [[-Types] <string[]>]
```
