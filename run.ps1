[CmdletBinding()]
param(
    [switch]$UseGui,
    [switch]$Console,
    [switch]$Audit,
    [switch]$QuickCheck,
    [string[]]$Targets = @('8.8.8.8', '1.1.1.1'),
    [int[]]$Ports = @(53, 80, 443),
    [string]$TicketTitle,
    [string]$TicketCategory = 'General',
    [ValidateSet('Low', 'Medium', 'High', 'Critical')]
    [string]$TicketPriority = 'Medium',
    [string]$TicketNotes = '',
    [string]$OutDir = '.\exports'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module (Join-Path $root 'src\Modules\SystemAudit.psm1') -Force
Import-Module (Join-Path $root 'src\Modules\ServiceCheck.psm1') -Force
Import-Module (Join-Path $root 'src\Modules\NetworkDiag.psm1') -Force
Import-Module (Join-Path $root 'src\Modules\TicketLogger.psm1') -Force
Import-Module (Join-Path $root 'src\Modules\ReportExport.psm1') -Force
. (Join-Path $root 'src\AppUi.ps1')

Initialize-FieldKitStorage -RootPath $root

function Resolve-OutputDirectory {
    param([string]$OutputDirectory)

    if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
        return $OutputDirectory
    }

    return (Join-Path $root $OutputDirectory)
}

function Show-Banner {
    Write-Host ''
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' ITOps FieldKit - Desktop Utility' -ForegroundColor Yellow
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ''
}

function Invoke-FullAudit {
    param(
        [string[]]$TargetList,
        [int[]]$PortList,
        [string]$OutputDirectory
    )

    Write-Host '[1/3] Collecting system audit...' -ForegroundColor Cyan
    $systemAudit = Get-SystemAudit

    Write-Host '[2/3] Checking tracked services...' -ForegroundColor Cyan
    $services = Get-TrackedServicesStatus -ConfigPath (Join-Path $root 'config\services.json')

    Write-Host '[3/3] Running network diagnostics...' -ForegroundColor Cyan
    $network = Test-NetworkTargets -Targets $TargetList -Ports $PortList

    $resolvedOutDir = Resolve-OutputDirectory -OutputDirectory $OutputDirectory
    $bundle = Export-OperationsBundle -SystemAudit $systemAudit -Services $services -Network $network -OutputDirectory $resolvedOutDir

    Write-Host ''
    Write-Host 'Audit completed successfully.' -ForegroundColor Green
    Write-Host ('JSON      : {0}' -f $bundle.Json) -ForegroundColor Gray
    Write-Host ('Services  : {0}' -f $bundle.ServicesCsv) -ForegroundColor Gray
    Write-Host ('Network   : {0}' -f $bundle.NetworkCsv) -ForegroundColor Gray
    Write-Host ('Summary   : {0}' -f $bundle.Summary) -ForegroundColor Gray
    Write-Host ('Dashboard : {0}' -f $bundle.Dashboard) -ForegroundColor Gray
    Write-Host ''

    return [PSCustomObject]@{
        SystemAudit = $systemAudit
        Services = $services
        Network = $network
        Output = $bundle
    }
}

function Get-QuickStatus {
    param(
        [string[]]$TargetList,
        [int[]]$PortList
    )

    $services = Get-TrackedServicesStatus -ConfigPath (Join-Path $root 'config\services.json')
    $network = Test-NetworkTargets -Targets $TargetList -Ports $PortList
    $systemAudit = Get-SystemAudit

    return [PSCustomObject]@{
        SystemAudit = $systemAudit
        Services = $services
        Network = $network
        RunningServices = ($services | Where-Object Status -eq 'Running').Count
        StoppedServices = ($services | Where-Object Status -eq 'Stopped').Count
        MissingServices = ($services | Where-Object Status -eq 'Missing').Count
        ReachableHosts = ($network | Where-Object Reachable -eq $true | Select-Object -ExpandProperty Target -Unique).Count
        CheckedHosts = ($network | Select-Object -ExpandProperty Target -Unique).Count
    }
}

function Show-QuickSummary {
    param(
        [string[]]$TargetList,
        [int[]]$PortList
    )

    $summary = Get-QuickStatus -TargetList $TargetList -PortList $PortList

    Write-Host ''
    Write-Host 'Quick Check Summary' -ForegroundColor Yellow
    Write-Host '-------------------' -ForegroundColor Yellow
    Write-Host ('Computer         : {0}' -f $summary.SystemAudit.ComputerName)
    Write-Host ('User             : {0}' -f $summary.SystemAudit.UserName)
    Write-Host ('Health           : {0}' -f $summary.SystemAudit.HealthStatus)
    Write-Host ('OS               : {0} ({1})' -f $summary.SystemAudit.OSName, $summary.SystemAudit.OSVersion)
    Write-Host ('Last Boot        : {0}' -f $summary.SystemAudit.LastBootTime)
    Write-Host ('Uptime Hours     : {0}' -f $summary.SystemAudit.UptimeHours)
    Write-Host ('Running services : {0}' -f $summary.RunningServices)
    Write-Host ('Stopped services : {0}' -f $summary.StoppedServices)
    Write-Host ('Missing services : {0}' -f $summary.MissingServices)
    Write-Host ('Reachable hosts  : {0}' -f $summary.ReachableHosts)
    Write-Host ('Checked hosts    : {0}' -f $summary.CheckedHosts)
    Write-Host ''
}

function Show-LatestTickets {
    $tickets = Get-ServiceTickets -RootPath $root | Select-Object -First 10
    Write-Host ''

    if (-not $tickets) {
        Write-Host 'No tickets found.' -ForegroundColor Yellow
        Write-Host ''
        return
    }

    $tickets | Format-Table Id, CreatedAt, Priority, Status, Category, Title -AutoSize
    Write-Host ''
}

function Start-ConsoleMode {
    Show-Banner

    do {
        Write-Host '1. Run full audit and export report'
        Write-Host '2. Run quick check'
        Write-Host '3. Log a support ticket'
        Write-Host '4. Show latest tickets'
        Write-Host '0. Exit'
        Write-Host ''

        $choice = Read-Host 'Select menu'

        switch ($choice) {
            '1' {
                try {
                    Invoke-FullAudit -TargetList $Targets -PortList $Ports -OutputDirectory $OutDir | Out-Null
                } catch {
                    Write-Host ''
                    Write-Host ('Audit failed: {0}' -f $_.Exception.Message) -ForegroundColor Red
                    Write-Host ''
                }
            }
            '2' {
                try {
                    Show-QuickSummary -TargetList $Targets -PortList $Ports
                } catch {
                    Write-Host ''
                    Write-Host ('Quick check failed: {0}' -f $_.Exception.Message) -ForegroundColor Red
                    Write-Host ''
                }
            }
            '3' {
                try {
                    $title = Read-Host 'Ticket title'
                    $category = Read-Host 'Category'
                    if (-not $category) { $category = 'General' }

                    $priority = Read-Host 'Priority (Low, Medium, High, Critical)'
                    if (-not $priority) { $priority = 'Medium' }

                    $notes = Read-Host 'Notes'
                    $ticket = New-ServiceTicket -RootPath $root -Title $title -Category $category -Priority $priority -Notes $notes

                    Write-Host ''
                    Write-Host ('Ticket logged: {0}' -f $ticket.Id) -ForegroundColor Green
                    Write-Host ''
                } catch {
                    Write-Host ''
                    Write-Host ('Ticket save failed: {0}' -f $_.Exception.Message) -ForegroundColor Red
                    Write-Host ''
                }
            }
            '4' {
                Show-LatestTickets
            }
            '0' {
                Write-Host ''
                Write-Host 'Closing ITOps FieldKit.' -ForegroundColor Cyan
                Write-Host ''
            }
            default {
                Write-Host ''
                Write-Host 'Invalid choice. Please select again.' -ForegroundColor Red
                Write-Host ''
            }
        }
    } while ($choice -ne '0')
}

function Try-StartGui {
    $isWindowsHost = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
    if (-not $isWindowsHost) {
        return $false
    }

    try {
        Show-FieldKitGui -RootPath $root -Targets $Targets -Ports $Ports -OutDir $OutDir
        return $true
    } catch {
        Write-Warning ('GUI launch failed. Falling back to console mode. {0}' -f $_.Exception.Message)
        return $false
    }
}

if ($TicketTitle) {
    $ticket = New-ServiceTicket -RootPath $root -Title $TicketTitle -Category $TicketCategory -Priority $TicketPriority -Notes $TicketNotes
    Write-Host ('Ticket logged: {0}' -f $ticket.Id) -ForegroundColor Green
    return
}

if ($QuickCheck) {
    Show-QuickSummary -TargetList $Targets -PortList $Ports
    return
}

if ($Audit) {
    Invoke-FullAudit -TargetList $Targets -PortList $Ports -OutputDirectory $OutDir | Out-Null
    return
}

if ($UseGui -or (-not $Console)) {
    if (Try-StartGui) {
        return
    }
}

Start-ConsoleMode
