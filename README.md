<div align="center">

<!-- Animated Wave Header -->
<img src="https://capsule-render.vercel.app/api?type=waving&height=220&color=0:0f172a,35:1d4ed8,70:06b6d4,100:22d3ee&text=ITOps%20FieldKit&fontSize=54&fontColor=ffffff&animation=fadeIn&fontAlignY=36&desc=PowerShell%20Desktop%20Utility%20for%20IT%20Support%20%7C%20Audit%20%2B%20Network%20%2B%20Ticketing&descAlignY=58" />

<!-- Typing SVG -->
<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=18&duration=2800&pause=700&color=22C55E&center=true&vCenter=true&width=920&lines=Windows+audit+tool+for+real+IT+operations;Service+health+checks%2C+network+diagnostics%2C+ticket+logging;Exports+JSON%2C+CSV%2C+Markdown%2C+and+HTML+reports" />

<br />

<img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white" />
<img src="https://img.shields.io/badge/Windows-Desktop-0078D6?style=for-the-badge&logo=windows&logoColor=white" />
<img src="https://img.shields.io/badge/WinForms-GUI-14B8A6?style=for-the-badge&logo=dotnet&logoColor=white" />
<img src="https://img.shields.io/badge/Reports-JSON%20CSV%20HTML-16A34A?style=for-the-badge" />

</div>

---

## Project Overview

**ITOps FieldKit** is a practical desktop-style utility built with **PowerShell + Windows Forms** for day-to-day IT work on Windows machines. It helps you collect a system snapshot, monitor selected services, test host and port reachability, log simple helpdesk tickets, and export shareable operational reports.

It is designed to feel useful for real entry-level to junior roles such as:

- **IT Support**
- **Helpdesk**
- **IT Generalist**
- **Network Support**
- **System Operations**

---

## Why This Project Is Useful

Instead of being a toy script, this project mirrors common tasks found in support and operations workflows:

- **Before troubleshooting**
  - Gather a fast machine health summary
  - Check uptime, disk space, OS, and user context
- **During validation**
  - Verify whether important Windows services are running
  - Check if target hosts respond and whether key ports are reachable
- **For documentation**
  - Save tickets locally for a simple incident trail
  - Export structured reports for handoff, review, or follow-up

---

## Core Features

- **Desktop GUI by default**
  - Launches a Windows Forms app for quick actions
  - Provides a more app-like experience than a plain script menu
- **Console fallback**
  - Automatically falls back if the GUI cannot be opened
- **System audit**
  - Collects device, OS, CPU, memory, disk, IP, uptime, and health data
- **Tracked service monitoring**
  - Reads service names from `config/services.json`
  - Marks them as **Running**, **Stopped**, or **Missing**
- **Network diagnostics**
  - Tests host reachability with ping
  - Tests selected TCP ports
- **Local ticket logging**
  - Saves support entries to `data/tickets.json`
- **Operational export bundle**
  - Generates machine-readable and human-readable output files

---

## Real-World Workflow

1. **Open the app** to inspect a user device.
2. **Run Quick Check** for a fast health summary.
3. **Run Full Audit** when you need evidence and exportable reports.
4. **Log a ticket** if an incident needs documentation.
5. **Review the HTML dashboard** or CSV files for follow-up.

---

## Output Files

When you run a full audit, the app writes a report bundle into the `exports` folder.

| File | Purpose |
|---|---|
| `snapshot-*.json` | Full structured device, service, and network snapshot |
| `services-*.csv` | Spreadsheet-friendly service status list |
| `network-*.csv` | Host reachability and port check results |
| `summary-*.md` | Human-readable operational summary |
| `dashboard-*.html` | Browser-ready report for quick review |

---

## What The Results Mean

### Quick Check

Quick Check is a compact operational summary for fast triage.

- **Computer / User** = the active machine and current signed-in user
- **Health** = a simple flag based mainly on available disk space
- **OS** = detected Windows name and version
- **Last Boot / Uptime Hours** = helps identify restart history or very long uptime
- **Running services** = tracked services that are active
- **Stopped services** = tracked services that exist but are not running
- **Missing services** = service names listed in config but not found on the machine
- **Reachable hosts** = how many targets answered network checks
- **Checked hosts** = how many unique hosts were tested

### Full Audit

Full Audit includes the same checks as Quick Check, then saves all outputs for documentation.

Use it when you need:

- evidence for escalation
- a handoff to another technician
- a saved troubleshooting record
- a quick HTML dashboard for review

### Ticket Logging

Ticket logging simulates a simple local helpdesk record.

- **Id** = internal ticket identifier
- **Priority** = Low, Medium, High, or Critical
- **Status** = defaults to Open
- **Category** = issue grouping such as Network, Account, Printer, or General
- **Notes** = observed symptoms or action details

---

## Stability Fix Included

This build already includes the fix for the boot-time conversion issue that caused the earlier crash.

The older logic forced this conversion:

```powershell
[System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
```

That can fail on systems where `LastBootUpTime` is already a **DateTime** object instead of a DMTF string.

This version is safer because it:

- checks whether the value is already a `DateTime`
- only uses DMTF conversion when the value matches a DMTF pattern
- falls back to normal parsing if needed
- prevents the app from dropping out of the menu for this case

---

## Project Structure

```text
itops-fieldkit-app-main/
├─ assets/
│  └─ preview/
│     └─ notes.txt
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

## Run The App

### GUI mode (default)

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1
```

### Console mode

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -Console
```

### Run full audit directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -Audit
```

### Run quick check directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -QuickCheck
```

### Log a ticket directly

```powershell
cd path\to\itops-fieldkit-app-main
Set-ExecutionPolicy -Scope Process Bypass
.\run.ps1 -TicketTitle "VPN cannot connect" -TicketCategory "Network" -TicketPriority High -TicketNotes "User cannot reach office VPN gateway."
```

---

## Tech Stack

- **PowerShell** for orchestration and CLI behavior
- **Windows Forms** for the desktop GUI
- **JSON** for config and ticket storage
- **CSV** for spreadsheet-friendly exports
- **Markdown** for quick summary exports
- **HTML** for a lightweight report dashboard

---

## Best Use Cases

This project is especially suitable for portfolio demos aimed at:

- **IT Support internship / junior roles**
- **Helpdesk analyst applications**
- **IT operations and infrastructure support**
- **Entry-level network support**
- **General technical support portfolios**

---

## Notes

- The app is intended for **Windows**.
- If GUI startup fails, it should **fall back to console mode**.
- You can change monitored services in `config/services.json`.
- Exported files are created in the `exports` folder.
- The project is built to be practical, readable, and easy to extend.

---
