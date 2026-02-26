function New-SummaryMarkdown {
    param(
        [pscustomobject]$SystemAudit,
        [object[]]$Services,
        [object[]]$Network,
        [datetime]$GeneratedAt
    )

    $runningCount = ($Services | Where-Object Status -eq 'Running').Count
    $stoppedCount = ($Services | Where-Object Status -eq 'Stopped').Count
    $missingCount = ($Services | Where-Object Status -eq 'Missing').Count
    $reachableTargets = ($Network | Where-Object Reachable -eq $true | Select-Object -ExpandProperty Target -Unique)
    $checkedTargets = ($Network | Select-Object -ExpandProperty Target -Unique)

    $lines = @(
        '# ITOps FieldKit Summary',
        '',
        ('Generated At: {0}' -f $GeneratedAt.ToString('yyyy-MM-dd HH:mm:ss')),
        '',
        '## System',
        ('- Computer: {0}' -f $SystemAudit.ComputerName),
        ('- User: {0}' -f $SystemAudit.UserName),
        ('- Health: {0}' -f $SystemAudit.HealthStatus),
        ('- OS: {0} ({1})' -f $SystemAudit.OSName, $SystemAudit.OSVersion),
        ('- Last Boot: {0}' -f $(if ($SystemAudit.LastBootTime) { $SystemAudit.LastBootTime } else { 'Unavailable' })),
        ('- Uptime Hours: {0}' -f $SystemAudit.UptimeHours),
        ('- RAM GB: {0}' -f $SystemAudit.RAMGB),
        ('- Total Disk GB: {0}' -f $SystemAudit.TotalDiskGB),
        ('- Free Disk GB: {0}' -f $SystemAudit.FreeDiskGB),
        ('- IPv4: {0}' -f $SystemAudit.IPv4),
        '',
        '## Services',
        ('- Running: {0}' -f $runningCount),
        ('- Stopped: {0}' -f $stoppedCount),
        ('- Missing: {0}' -f $missingCount),
        '',
        '## Network',
        ('- Reachable Targets: {0}' -f $reachableTargets.Count),
        ('- Checked Targets: {0}' -f $checkedTargets.Count)
    )

    if ($reachableTargets.Count -gt 0) {
        $lines += ('- Reachable List: {0}' -f ($reachableTargets -join ', '))
    }

    return ($lines -join [Environment]::NewLine)
}

function ConvertTo-HtmlSafe {
    param([object]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return ([System.Net.WebUtility]::HtmlEncode([string]$Value))
}

function New-HtmlReport {
    param(
        [pscustomobject]$SystemAudit,
        [object[]]$Services,
        [object[]]$Network,
        [datetime]$GeneratedAt
    )

    $runningCount = ($Services | Where-Object Status -eq 'Running').Count
    $stoppedCount = ($Services | Where-Object Status -eq 'Stopped').Count
    $missingCount = ($Services | Where-Object Status -eq 'Missing').Count

    $serviceRows = foreach ($item in $Services) {
        '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f (
            ConvertTo-HtmlSafe $item.Name
        ), (
            ConvertTo-HtmlSafe $item.Status
        ), (
            ConvertTo-HtmlSafe $item.StartType
        ), (
            ConvertTo-HtmlSafe $item.DisplayName
        )
    }

    $networkRows = foreach ($item in $Network) {
        '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>' -f (
            ConvertTo-HtmlSafe $item.Target
        ), (
            ConvertTo-HtmlSafe $item.Reachable
        ), (
            ConvertTo-HtmlSafe $item.LatencyMs
        ), (
            ConvertTo-HtmlSafe $item.Port
        ), (
            ConvertTo-HtmlSafe $item.PortStatus
        )
    }

    return @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>ITOps FieldKit Dashboard</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 24px; background: #f5f7fb; color: #1f2937; }
h1, h2 { margin-bottom: 8px; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin: 16px 0 24px; }
.card { background: white; border-radius: 14px; padding: 14px 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.06); }
th, td { padding: 10px 12px; border-bottom: 1px solid #e5e7eb; text-align: left; }
th { background: #111827; color: white; }
small { color: #6b7280; }
</style>
</head>
<body>
<h1>ITOps FieldKit Dashboard</h1>
<small>Generated at $($GeneratedAt.ToString('yyyy-MM-dd HH:mm:ss'))</small>

<div class="grid">
  <div class="card"><strong>Computer</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]$SystemAudit.ComputerName))</div>
  <div class="card"><strong>User</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]$SystemAudit.UserName))</div>
  <div class="card"><strong>Health</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]$SystemAudit.HealthStatus))</div>
  <div class="card"><strong>OS</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]("{0} ({1})" -f $SystemAudit.OSName, $SystemAudit.OSVersion)))</div>
  <div class="card"><strong>Uptime Hours</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]$SystemAudit.UptimeHours))</div>
  <div class="card"><strong>IPv4</strong><br>$([System.Net.WebUtility]::HtmlEncode([string]$SystemAudit.IPv4))</div>
  <div class="card"><strong>Services Running</strong><br>$runningCount</div>
  <div class="card"><strong>Services Stopped</strong><br>$stoppedCount</div>
  <div class="card"><strong>Services Missing</strong><br>$missingCount</div>
</div>

<h2>Tracked Services</h2>
<table>
  <thead>
    <tr><th>Name</th><th>Status</th><th>Start Type</th><th>Display Name</th></tr>
  </thead>
  <tbody>
    $($serviceRows -join [Environment]::NewLine)
  </tbody>
</table>

<h2 style="margin-top:24px;">Network Diagnostics</h2>
<table>
  <thead>
    <tr><th>Target</th><th>Reachable</th><th>Latency (ms)</th><th>Port</th><th>Port Status</th></tr>
  </thead>
  <tbody>
    $($networkRows -join [Environment]::NewLine)
  </tbody>
</table>
</body>
</html>
"@
}

function Export-OperationsBundle {
    param(
        [pscustomobject]$SystemAudit,
        [object[]]$Services,
        [object[]]$Network,
        [string]$OutputDirectory
    )

    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $generatedAt = Get-Date

    $bundle = [PSCustomObject]@{
        GeneratedAt = $generatedAt
        SystemAudit = $SystemAudit
        Services = $Services
        Network = $Network
    }

    $jsonPath = Join-Path $OutputDirectory ("snapshot-{0}.json" -f $stamp)
    $servicesCsvPath = Join-Path $OutputDirectory ("services-{0}.csv" -f $stamp)
    $networkCsvPath = Join-Path $OutputDirectory ("network-{0}.csv" -f $stamp)
    $summaryPath = Join-Path $OutputDirectory ("summary-{0}.md" -f $stamp)
    $dashboardPath = Join-Path $OutputDirectory ("dashboard-{0}.html" -f $stamp)

    $bundle | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath -Encoding UTF8
    $Services | Export-Csv -Path $servicesCsvPath -NoTypeInformation -Encoding UTF8
    $Network | Export-Csv -Path $networkCsvPath -NoTypeInformation -Encoding UTF8

    $summary = New-SummaryMarkdown -SystemAudit $SystemAudit -Services $Services -Network $Network -GeneratedAt $generatedAt
    $summary | Set-Content -Path $summaryPath -Encoding UTF8

    $html = New-HtmlReport -SystemAudit $SystemAudit -Services $Services -Network $Network -GeneratedAt $generatedAt
    $html | Set-Content -Path $dashboardPath -Encoding UTF8

    return [PSCustomObject]@{
        Json = $jsonPath
        ServicesCsv = $servicesCsvPath
        NetworkCsv = $networkCsvPath
        Summary = $summaryPath
        Dashboard = $dashboardPath
    }
}

Export-ModuleMember -Function Export-OperationsBundle
