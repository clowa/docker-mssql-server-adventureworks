$DockerTag = "clowa/mssql-server-adventureworks2017"
$Platform = @("linux/amd64")
$Types = @(
    "LT",
    "DW",
    ""
)

$Years = @(
    "2019",
    "2017",
    "2016",
    "2014"
    "2012"
)

[Array]::Sort($Types)
[Array]::Sort($Years)

foreach ($y in $Years) {
    Write-Host "Processing version of year $y"
    docker manifest inspect "mcr.microsoft.com/mssql/server:$y-latest" *> $null
    if ($LASTEXITCODE) { continue; }

    foreach ($t in $Types) {
        Write-Host "Processing $($DockerTag):$y$t"
        $cmd = "docker buildx build --platform $($Platform -join ',') --tag $($DockerTag):$y$t --build-arg MSSQLYear=$y --build-arg AdventureWorksYear=$y --build-arg AdventureWorksType=$t . --push"
        Invoke-Expression $cmd
        # Start-Job { Invoke-Expression $cmd }
    }
}