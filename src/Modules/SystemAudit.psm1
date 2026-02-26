function Convert-BytesToGigabytes {
    param([double]$Value)

    if (-not $Value -or $Value -le 0) {
        return 0
    }

    return [Math]::Round(($Value / 1GB), 2)
}

function Convert-ToSafeDateTime {
    param([object]$Value)

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [datetime]) {
        return [datetime]$Value
    }

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    if ($text -match '^\d{14}\.\d{6}[\+\-]\d{3}$') {
        try {
            return [System.Management.ManagementDateTimeConverter]::ToDateTime($text)
        } catch {
        }
    }

    $parsed = [datetime]::MinValue
    if ([datetime]::TryParse($text, [ref]$parsed)) {
        return $parsed
    }

    try {
        return [datetime]$Value
    } catch {
        return $null
    }
}

function Get-PreferredIPv4Address {
    try {
        if (Get-Command -Name Get-NetIPAddress -ErrorAction SilentlyContinue) {
            $addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
                Where-Object {
                    $_.IPAddress -ne '127.0.0.1' -and
                    $_.IPAddress -notlike '169.254*' -and
                    $_.PrefixOrigin -ne 'WellKnown'
                } |
                Select-Object -ExpandProperty IPAddress

            if ($addresses) {
                return ($addresses -join ', ')
            }
        }
    } catch {
    }

    try {
        $fallback = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
            Where-Object { $_.OperationalStatus -eq 'Up' } |
            ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
            Where-Object {
                $_.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork -and
                $_.Address.IPAddressToString -ne '127.0.0.1' -and
                $_.Address.IPAddressToString -notlike '169.254*'
            } |
            ForEach-Object { $_.Address.IPAddressToString }

        if ($fallback) {
            return ($fallback -join ', ')
        }
    } catch {
    }

    return 'Unavailable'
}

function Get-LogicalDiskStats {
    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
        return [PSCustomObject]@{
            TotalBytes = ($disks | Measure-Object -Property Size -Sum).Sum
            FreeBytes = ($disks | Measure-Object -Property FreeSpace -Sum).Sum
        }
    } catch {
        try {
            $drives = Get-PSDrive -PSProvider FileSystem -ErrorAction Stop
            return [PSCustomObject]@{
                TotalBytes = ($drives | Measure-Object -Property Used -Sum).Sum + ($drives | Measure-Object -Property Free -Sum).Sum
                FreeBytes = ($drives | Measure-Object -Property Free -Sum).Sum
            }
        } catch {
            return [PSCustomObject]@{
                TotalBytes = 0
                FreeBytes = 0
            }
        }
    }
}

function Get-SystemAudit {
    try {
        $computer = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $processor = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        $diskStats = Get-LogicalDiskStats

        $bootTime = Convert-ToSafeDateTime -Value $os.LastBootUpTime
        $installDate = Convert-ToSafeDateTime -Value $os.InstallDate
        $uptimeHours = 0

        if ($bootTime) {
            $uptime = New-TimeSpan -Start $bootTime -End (Get-Date)
            $uptimeHours = [Math]::Round($uptime.TotalHours, 2)
        }

        $healthStatus = 'Healthy'
        if ($diskStats.TotalBytes -gt 0) {
            $freePercent = [Math]::Round((($diskStats.FreeBytes / $diskStats.TotalBytes) * 100), 2)
            if ($freePercent -lt 10) {
                $healthStatus = 'Warning'
            }
        }

        return [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Manufacturer = $computer.Manufacturer
            Model = $computer.Model
            OSName = $os.Caption
            OSVersion = $os.Version
            InstallDate = $installDate
            LastBootTime = $bootTime
            UptimeHours = $uptimeHours
            CPU = if ($processor) { $processor.Name } else { 'Unavailable' }
            LogicalProcessors = if ($processor) { $processor.NumberOfLogicalProcessors } else { 0 }
            RAMGB = Convert-BytesToGigabytes -Value $computer.TotalPhysicalMemory
            TotalDiskGB = Convert-BytesToGigabytes -Value $diskStats.TotalBytes
            FreeDiskGB = Convert-BytesToGigabytes -Value $diskStats.FreeBytes
            IPv4 = Get-PreferredIPv4Address
            HealthStatus = $healthStatus
        }
    } catch {
        throw "Failed to collect system audit data. $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Get-SystemAudit
