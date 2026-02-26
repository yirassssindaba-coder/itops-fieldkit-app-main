function Show-FieldKitGui {
    param(
        [string]$RootPath,
        [string[]]$Targets,
        [int[]]$Ports,
        [string]$OutDir
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'ITOps FieldKit'
    $form.Size = New-Object System.Drawing.Size(1080, 760)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 251)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'ITOps FieldKit - Desktop Utility'
    $title.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(20, 18)
    $form.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = 'Audit Windows device, check service and network health, log support tickets, and export reports.'
    $subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $subtitle.AutoSize = $true
    $subtitle.Location = New-Object System.Drawing.Point(22, 50)
    $form.Controls.Add($subtitle)

    $buttonAudit = New-Object System.Windows.Forms.Button
    $buttonAudit.Text = 'Run Full Audit'
    $buttonAudit.Size = New-Object System.Drawing.Size(130, 34)
    $buttonAudit.Location = New-Object System.Drawing.Point(20, 88)
    $form.Controls.Add($buttonAudit)

    $buttonQuick = New-Object System.Windows.Forms.Button
    $buttonQuick.Text = 'Quick Check'
    $buttonQuick.Size = New-Object System.Drawing.Size(130, 34)
    $buttonQuick.Location = New-Object System.Drawing.Point(160, 88)
    $form.Controls.Add($buttonQuick)

    $buttonRefresh = New-Object System.Windows.Forms.Button
    $buttonRefresh.Text = 'Refresh Tickets'
    $buttonRefresh.Size = New-Object System.Drawing.Size(130, 34)
    $buttonRefresh.Location = New-Object System.Drawing.Point(300, 88)
    $form.Controls.Add($buttonRefresh)

    $buttonOpenExports = New-Object System.Windows.Forms.Button
    $buttonOpenExports.Text = 'Open Exports'
    $buttonOpenExports.Size = New-Object System.Drawing.Size(130, 34)
    $buttonOpenExports.Location = New-Object System.Drawing.Point(440, 88)
    $form.Controls.Add($buttonOpenExports)

    $summaryBox = New-Object System.Windows.Forms.GroupBox
    $summaryBox.Text = 'Current Summary'
    $summaryBox.Size = New-Object System.Drawing.Size(510, 190)
    $summaryBox.Location = New-Object System.Drawing.Point(20, 140)
    $form.Controls.Add($summaryBox)

    $summaryText = New-Object System.Windows.Forms.TextBox
    $summaryText.Multiline = $true
    $summaryText.ReadOnly = $true
    $summaryText.ScrollBars = 'Vertical'
    $summaryText.Font = New-Object System.Drawing.Font('Consolas', 10)
    $summaryText.Dock = 'Fill'
    $summaryBox.Controls.Add($summaryText)

    $logBox = New-Object System.Windows.Forms.GroupBox
    $logBox.Text = 'Activity Log'
    $logBox.Size = New-Object System.Drawing.Size(510, 350)
    $logBox.Location = New-Object System.Drawing.Point(20, 340)
    $form.Controls.Add($logBox)

    $logText = New-Object System.Windows.Forms.TextBox
    $logText.Multiline = $true
    $logText.ReadOnly = $true
    $logText.ScrollBars = 'Vertical'
    $logText.Font = New-Object System.Drawing.Font('Consolas', 9)
    $logText.Dock = 'Fill'
    $logBox.Controls.Add($logText)

    $ticketBox = New-Object System.Windows.Forms.GroupBox
    $ticketBox.Text = 'Support Ticket'
    $ticketBox.Size = New-Object System.Drawing.Size(500, 250)
    $ticketBox.Location = New-Object System.Drawing.Point(545, 140)
    $form.Controls.Add($ticketBox)

    $labelTitle = New-Object System.Windows.Forms.Label
    $labelTitle.Text = 'Title'
    $labelTitle.AutoSize = $true
    $labelTitle.Location = New-Object System.Drawing.Point(16, 32)
    $ticketBox.Controls.Add($labelTitle)

    $inputTitle = New-Object System.Windows.Forms.TextBox
    $inputTitle.Size = New-Object System.Drawing.Size(460, 24)
    $inputTitle.Location = New-Object System.Drawing.Point(16, 52)
    $ticketBox.Controls.Add($inputTitle)

    $labelCategory = New-Object System.Windows.Forms.Label
    $labelCategory.Text = 'Category'
    $labelCategory.AutoSize = $true
    $labelCategory.Location = New-Object System.Drawing.Point(16, 86)
    $ticketBox.Controls.Add($labelCategory)

    $inputCategory = New-Object System.Windows.Forms.TextBox
    $inputCategory.Text = 'General'
    $inputCategory.Size = New-Object System.Drawing.Size(220, 24)
    $inputCategory.Location = New-Object System.Drawing.Point(16, 106)
    $ticketBox.Controls.Add($inputCategory)

    $labelPriority = New-Object System.Windows.Forms.Label
    $labelPriority.Text = 'Priority'
    $labelPriority.AutoSize = $true
    $labelPriority.Location = New-Object System.Drawing.Point(256, 86)
    $ticketBox.Controls.Add($labelPriority)

    $inputPriority = New-Object System.Windows.Forms.ComboBox
    $inputPriority.DropDownStyle = 'DropDownList'
    [void]$inputPriority.Items.AddRange(@('Low', 'Medium', 'High', 'Critical'))
    $inputPriority.SelectedIndex = 1
    $inputPriority.Size = New-Object System.Drawing.Size(220, 24)
    $inputPriority.Location = New-Object System.Drawing.Point(256, 106)
    $ticketBox.Controls.Add($inputPriority)

    $labelNotes = New-Object System.Windows.Forms.Label
    $labelNotes.Text = 'Notes'
    $labelNotes.AutoSize = $true
    $labelNotes.Location = New-Object System.Drawing.Point(16, 142)
    $ticketBox.Controls.Add($labelNotes)

    $inputNotes = New-Object System.Windows.Forms.TextBox
    $inputNotes.Multiline = $true
    $inputNotes.Size = New-Object System.Drawing.Size(460, 64)
    $inputNotes.Location = New-Object System.Drawing.Point(16, 162)
    $ticketBox.Controls.Add($inputNotes)

    $buttonSaveTicket = New-Object System.Windows.Forms.Button
    $buttonSaveTicket.Text = 'Save Ticket'
    $buttonSaveTicket.Size = New-Object System.Drawing.Size(120, 32)
    $buttonSaveTicket.Location = New-Object System.Drawing.Point(356, 214)
    $ticketBox.Controls.Add($buttonSaveTicket)

    $ticketsViewBox = New-Object System.Windows.Forms.GroupBox
    $ticketsViewBox.Text = 'Latest Tickets'
    $ticketsViewBox.Size = New-Object System.Drawing.Size(500, 290)
    $ticketsViewBox.Location = New-Object System.Drawing.Point(545, 400)
    $form.Controls.Add($ticketsViewBox)

    $ticketsGrid = New-Object System.Windows.Forms.DataGridView
    $ticketsGrid.Dock = 'Fill'
    $ticketsGrid.ReadOnly = $true
    $ticketsGrid.AllowUserToAddRows = $false
    $ticketsGrid.AllowUserToDeleteRows = $false
    $ticketsGrid.AutoSizeColumnsMode = 'Fill'
    $ticketsGrid.SelectionMode = 'FullRowSelect'
    $ticketsViewBox.Controls.Add($ticketsGrid)

    function Write-AppLog {
        param([string]$Message)

        $timestamp = Get-Date -Format 'HH:mm:ss'
        $logText.AppendText("[$timestamp] $Message" + [Environment]::NewLine)
    }

    function Set-SummaryText {
        param(
            [pscustomobject]$SystemAudit,
            [object[]]$Services,
            [object[]]$Network
        )

        $runningCount = ($Services | Where-Object Status -eq 'Running').Count
        $stoppedCount = ($Services | Where-Object Status -eq 'Stopped').Count
        $missingCount = ($Services | Where-Object Status -eq 'Missing').Count
        $reachableCount = ($Network | Where-Object Reachable -eq $true | Select-Object -ExpandProperty Target -Unique).Count
        $checkedCount = ($Network | Select-Object -ExpandProperty Target -Unique).Count

        $summaryText.Text = @"
Computer       : $($SystemAudit.ComputerName)
User           : $($SystemAudit.UserName)
Health         : $($SystemAudit.HealthStatus)
OS             : $($SystemAudit.OSName) ($($SystemAudit.OSVersion))
Last Boot      : $($SystemAudit.LastBootTime)
Uptime Hours   : $($SystemAudit.UptimeHours)
CPU            : $($SystemAudit.CPU)
RAM GB         : $($SystemAudit.RAMGB)
Disk Free / Total GB : $($SystemAudit.FreeDiskGB) / $($SystemAudit.TotalDiskGB)
IPv4           : $($SystemAudit.IPv4)

Services       : Running=$runningCount | Stopped=$stoppedCount | Missing=$missingCount
Network        : Reachable Targets=$reachableCount | Checked Targets=$checkedCount
"@
    }

    function Refresh-TicketGrid {
        $rows = Get-ServiceTickets -RootPath $RootPath |
            Select-Object -First 10 |
            Select-Object Id, CreatedAt, Priority, Status, Category, Title

        $ticketsGrid.DataSource = $null
        if ($rows) {
            $ticketsGrid.DataSource = $rows
        }
    }

    function Run-QuickDashboard {
        Write-AppLog 'Running quick check...'
        $services = Get-TrackedServicesStatus -ConfigPath (Join-Path $RootPath 'config\services.json')
        $network = Test-NetworkTargets -Targets $Targets -Ports $Ports
        $systemAudit = Get-SystemAudit
        Set-SummaryText -SystemAudit $systemAudit -Services $services -Network $network
        Write-AppLog 'Quick check completed.'
    }

    $buttonQuick.Add_Click({
        try {
            Run-QuickDashboard
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Quick Check Error')
            Write-AppLog ("Quick check failed: {0}" -f $_.Exception.Message)
        }
    })

    $buttonAudit.Add_Click({
        try {
            Write-AppLog 'Running full audit and exporting report...'
            $result = Invoke-FullAudit -TargetList $Targets -PortList $Ports -OutputDirectory $OutDir
            Set-SummaryText -SystemAudit $result.SystemAudit -Services $result.Services -Network $result.Network
            Write-AppLog ("Audit completed. HTML dashboard: {0}" -f $result.Output.Dashboard)
            [System.Windows.Forms.MessageBox]::Show(
                "Audit complete.`n`nJSON: $($result.Output.Json)`nServices CSV: $($result.Output.ServicesCsv)`nNetwork CSV: $($result.Output.NetworkCsv)`nSummary: $($result.Output.Summary)`nDashboard: $($result.Output.Dashboard)",
                'Audit Complete'
            ) | Out-Null
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Audit Error')
            Write-AppLog ("Audit failed: {0}" -f $_.Exception.Message)
        }
    })

    $buttonSaveTicket.Add_Click({
        try {
            $ticket = New-ServiceTicket -RootPath $RootPath -Title $inputTitle.Text -Category $inputCategory.Text -Priority $inputPriority.SelectedItem.ToString() -Notes $inputNotes.Text
            Write-AppLog ("Ticket saved: {0}" -f $ticket.Id)
            $inputTitle.Clear()
            $inputNotes.Clear()
            Refresh-TicketGrid
            [System.Windows.Forms.MessageBox]::Show(("Ticket saved successfully: {0}" -f $ticket.Id), 'Ticket Saved') | Out-Null
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Ticket Error')
            Write-AppLog ("Ticket save failed: {0}" -f $_.Exception.Message)
        }
    })

    $buttonRefresh.Add_Click({
        Refresh-TicketGrid
        Write-AppLog 'Ticket list refreshed.'
    })

    $buttonOpenExports.Add_Click({
        $exportsPath = Join-Path $RootPath 'exports'
        if (-not (Test-Path $exportsPath)) {
            New-Item -ItemType Directory -Path $exportsPath -Force | Out-Null
        }

        Start-Process explorer.exe $exportsPath
        Write-AppLog 'Opened exports folder.'
    })

    $form.Add_Shown({
        try {
            Refresh-TicketGrid
            Run-QuickDashboard
            Write-AppLog 'Desktop utility is ready.'
        } catch {
            Write-AppLog ("Startup warning: {0}" -f $_.Exception.Message)
        }
    })

    [void]$form.ShowDialog()
}
