# Overview

**This image is not actively maintained !!!**

This is an image with a MSSQL Server Express Edition and the sample AdventureWorks database preinstalled.
The image was built for educational and testing purposes.

See [GitHub](https://github.com/clowa/docker-mssql-server-adventureworks) to take a look at the code.

## Environment variables

```
ACCEPT_EULA=Y
SA_PASSWORD=!demo54321
MSSQL_PID=Express

```

# How to use

Start container. Make sure to edit `tagname` as needed.

```bash
docker run --rm -it -p 1433:1433 clowa/mssql-server-adventureworks:tagname
```

This will download the image, start the container in foreground and expose mssql server on port `1433` of the host.

# Load database on startup

The container is loading the AdventureWorks database on startup from `/init-databases/`. You can use this behavior and load any other database by placing the `.bak` file within this folder. The file name has to be the same as the name of database.
