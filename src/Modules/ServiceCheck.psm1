function Get-ServiceConfig {
    param([string]$ConfigPath)

    $defaultServices = @('Spooler', 'EventLog', 'Dhcp', 'W32Time', 'Winmgmt')

    if (-not (Test-Path $ConfigPath)) {
        return $defaultServices
    }

    try {
        $content = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        if ($content.services -and $content.services.Count -gt 0) {
            return [string[]]$content.services
        }
    } catch {
    }

    return $defaultServices
}

function Get-TrackedServicesStatus {
    param([string]$ConfigPath)

    $serviceNames = Get-ServiceConfig -ConfigPath $ConfigPath

    $results = foreach ($serviceName in $serviceNames) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        $serviceWmi = Get-CimInstance -ClassName Win32_Service -Filter ("Name='{0}'" -f $serviceName) -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            Name = $serviceName
            Exists = [bool]$service
            Status = if ($service) { [string]$service.Status } else { 'Missing' }
            StartType = if ($serviceWmi) { [string]$serviceWmi.StartMode } else { 'N/A' }
            DisplayName = if ($service) { $service.DisplayName } else { 'N/A' }
        }
    }

    return $results
}

Export-ModuleMember -Function Get-TrackedServicesStatus
