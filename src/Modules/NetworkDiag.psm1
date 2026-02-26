function Test-HostReachability {
    param(
        [string]$Target,
        [int]$TimeoutMs = 1200
    )

    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($Target, $TimeoutMs)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            return [PSCustomObject]@{
                Reachable = $true
                LatencyMs = [Math]::Round([double]$reply.RoundtripTime, 2)
            }
        }
    } catch {
    }

    return [PSCustomObject]@{
        Reachable = $false
        LatencyMs = $null
    }
}

function Test-TcpPort {
    param(
        [string]$Target,
        [int]$Port,
        [int]$TimeoutMs = 1000
    )

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($Target, $Port, $null, $null)
        $connected = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

        if (-not $connected) {
            $client.Close()
            return 'TimedOut'
        }

        $client.EndConnect($iar) | Out-Null
        $client.Close()
        return 'Open'
    } catch {
        return 'Closed'
    }
}

function Test-NetworkTargets {
    param(
        [string[]]$Targets,
        [int[]]$Ports = @(53, 80, 443)
    )

    $cleanTargets = $Targets | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    if (-not $cleanTargets) {
        $cleanTargets = @('8.8.8.8', '1.1.1.1')
    }

    $results = foreach ($target in $cleanTargets) {
        $reachability = Test-HostReachability -Target $target

        foreach ($port in $Ports) {
            [PSCustomObject]@{
                Target = $target
                Reachable = $reachability.Reachable
                LatencyMs = $reachability.LatencyMs
                Port = $port
                PortStatus = Test-TcpPort -Target $target -Port $port
                CheckedAt = Get-Date
            }
        }
    }

    return $results
}

Export-ModuleMember -Function Test-NetworkTargets
