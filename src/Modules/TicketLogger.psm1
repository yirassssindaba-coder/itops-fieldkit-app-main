function Get-TicketStorePath {
    param([string]$RootPath)

    return (Join-Path $RootPath 'data\tickets.json')
}

function Initialize-FieldKitStorage {
    param([string]$RootPath)

    foreach ($relativePath in @('data', 'exports', 'config')) {
        $fullPath = Join-Path $RootPath $relativePath
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }

    $ticketStore = Get-TicketStorePath -RootPath $RootPath
    if (-not (Test-Path $ticketStore)) {
        @() | ConvertTo-Json | Set-Content -Path $ticketStore -Encoding UTF8
    }
}

function Read-TicketStore {
    param([string]$RootPath)

    $ticketStore = Get-TicketStorePath -RootPath $RootPath
    if (-not (Test-Path $ticketStore)) {
        return @()
    }

    $raw = Get-Content -Path $ticketStore -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or -not $raw.Trim()) {
        return @()
    }

    try {
        $items = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($items -is [System.Array]) {
            return @($items)
        }

        if ($items) {
            return @($items)
        }
    } catch {
        return @()
    }

    return @()
}

function Write-TicketStore {
    param(
        [string]$RootPath,
        [object[]]$Tickets
    )

    $ticketStore = Get-TicketStorePath -RootPath $RootPath
    $Tickets | ConvertTo-Json -Depth 5 | Set-Content -Path $ticketStore -Encoding UTF8
}

function New-ServiceTicket {
    param(
        [string]$RootPath,
        [string]$Title,
        [string]$Category = 'General',
        [string]$Priority = 'Medium',
        [string]$Notes = ''
    )

    if ([string]::IsNullOrWhiteSpace($Title)) {
        throw 'Ticket title cannot be empty.'
    }

    $allowed = @('Low', 'Medium', 'High', 'Critical')
    if ($allowed -notcontains $Priority) {
        $Priority = 'Medium'
    }

    if ([string]::IsNullOrWhiteSpace($Category)) {
        $Category = 'General'
    }

    $tickets = Read-TicketStore -RootPath $RootPath
    $ticket = [PSCustomObject]@{
        Id = 'INC-{0}-{1}' -f (Get-Date -Format 'yyyyMMdd'), (Get-Random -Minimum 1000 -Maximum 9999)
        Title = $Title.Trim()
        Category = $Category.Trim()
        Priority = $Priority
        Status = 'Open'
        Notes = $Notes.Trim()
        CreatedAt = Get-Date
        UpdatedAt = Get-Date
    }

    $newList = @($ticket) + @($tickets)
    Write-TicketStore -RootPath $RootPath -Tickets $newList

    return $ticket
}

function Get-ServiceTickets {
    param([string]$RootPath)

    return Read-TicketStore -RootPath $RootPath
}

Export-ModuleMember -Function Initialize-FieldKitStorage, New-ServiceTicket, Get-ServiceTickets
