<div align="center">

# ITOps FieldKit

**Desktop utility for IT Support, Network checks, ticket logging, and Windows operational reporting**

</div>

---

## Project Overview

ITOps FieldKit is a PowerShell desktop utility made for entry-level to junior IT work. It helps you audit a Windows device, check tracked services, test host and port reachability, log support tickets, and export a report bundle for operational follow-up.

---

## Why This Fits Real Jobs

This project maps directly to common tasks in:

- IT Support
- Helpdesk
- IT Generalist
- Network Support
- System Operations

You can use it to:

- Collect a quick machine health snapshot before troubleshooting
- Verify important Windows services
- Test external target reachability and port status
- Record support incidents in a simple local ticket file
- Export JSON, CSV, Markdown, and HTML reports for handoff or documentation

---

## Main Features

- **Desktop GUI** with buttons for audit, quick check, exports, and ticket actions
- **Console fallback** if GUI cannot be opened
- **Safe system audit** with compatible boot time parsing
- **Tracked service monitoring** from a JSON config file
- **Network diagnostics** using Ping and TCP port checks
- **Local ticket logging** to JSON
- **Report export bundle**:
  - JSON snapshot
  - CSV for services
  - CSV for network
  - Markdown summary
  - HTML dashboard

---

## Folder Structure

```text
itops-fieldkit-app-main/
├─ assets/
│  └─ preview/
├─ config/
│  └─ services.json
├─ data/
│  └─ tickets.json
├─ exports/
│  └─ .gitkeep
├─ src/
│  ├─ AppUi.ps1
│  └─ Modules/
│     ├─ NetworkDiag.psm1
│     ├─ ReportExport.psm1
│     ├─ ServiceCheck.psm1
│     ├─ SystemAudit.psm1
│     └─ TicketLogger.psm1
├─ .gitignore
├─ README.md
└─ run.ps1
```

---

## Output Meaning

### Quick Check

Quick Check shows a fast operational summary:

- **Computer / User**: active device name and current user
- **Health**: simple warning flag based on low free disk
- **OS**: detected Windows version
- **Last Boot / Uptime Hours**: helps detect restart history and long-running machines
- **Running / Stopped / Missing services**:
  - Running = service is active
  - Stopped = service exists but is not running
  - Missing = service name in config does not exist on the machine
- **Reachable hosts**:
  - How many target hosts replied to Ping
- **Checked hosts**:
  - How many unique targets were tested

### Full Audit

Full Audit does everything in Quick Check, then exports files:

- **snapshot-*.json**: full machine, service, and network data
- **services-*.csv**: service list for spreadsheet review
- **network-*.csv**: reachability and port test data
- **summary-*.md**: human-readable summary
- **dashboard-*.html**: browser-ready report for easier viewing

### Ticket Logging

Ticket entries simulate a simple helpdesk workflow:

- **Id**: incident-like identifier
- **Priority**: Low, Medium, High, Critical
- **Status**: defaults to Open
- **Category**: type of issue, such as Network, Printer, Account, or General
- **Notes**: what happened and what was observed

---

## Root Cause of Your Previous Error

Your earlier build crashed because the script tried to force this conversion:

- `ManagementDateTimeConverter.ToDateTime($os.LastBootUpTime)`

On some systems, `Get-CimInstance Win32_OperatingSystem` already returns **LastBootUpTime as a DateTime object**, not a DMTF string. Converting it again can throw:

- **Specified argument was out of the range of valid values. (Parameter 'dmtfDate')**

This version fixes that by:

- checking whether the value is already a DateTime
- only using DMTF conversion when the input is actually a DMTF string
- falling back safely if the value is blank or formatted differently

---

## Run Instructions

## GUI mode (default)

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1
```

## Console mode

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -Console
```

## Full audit directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -Audit
```

## Quick check directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -QuickCheck
```

## Log a ticket directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -TicketTitle "VPN cannot connect" -TicketCategory "Network" -TicketPriority High -TicketNotes "User cannot reach office VPN gateway."
```

---

## Notes

- The GUI is built with Windows Forms and is intended for Windows.
- If GUI load fails, the script automatically falls back to console mode.
- You can change tracked services in `config/services.json`.
- Exported files are written to the `exports` folder.

---
