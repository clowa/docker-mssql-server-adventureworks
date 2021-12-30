[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $DockerTag = "clowa/mssql-server-adventureworks",

    [Parameter()]
    [String[]]
    $Platform = @("linux/amd64"),

    [Parameter()]
    [String[]]
    # Docker images are starting at version of MSSQL 2017
    $Years = @(
        "2019",
        "2017"
    ),

    [Parameter()]
    [String[]]
    [ValidateSet("LT", "DW", "OLTP")]
    $Types = @(
        "LT",
        "DW",
        "OLTP"
    )
)

$Types[$Types.IndexOf("OLTP")] = ""

[Array]::Sort($Types)
[Array]::Sort($Years)

foreach ($y in $Years) {
    Write-Host "Processing version of year $y"
    docker manifest inspect "mcr.microsoft.com/mssql/server:$y-latest" *> $null
    if ($LASTEXITCODE) {
        Write-Warning "Docker image mcr.microsoft.com/mssql/server:$y-latest does not exist."
        continue
    }

    foreach ($t in $Types) {
        Write-Host "`tProcessing $($DockerTag):$y$t"
        $cmd = "docker buildx build --platform $($Platform -join ',') --tag $($DockerTag):$y$t --build-arg MSSQLYear=$y --build-arg AdventureWorksYear=$y --build-arg AdventureWorksType=$t . --push"
        Invoke-Expression $cmd
        # Start-Job { Invoke-Expression $cmd }
    }
}