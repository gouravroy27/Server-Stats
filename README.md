<div align="center">

```
███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗
██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝

███████╗ ████████╗  █████╗  ████████╗ ███████╗
██╔════╝ ╚══██╔══╝ ██╔══██╗ ╚══██╔══╝ ██╔════╝
███████╗    ██║    ███████║    ██║    ███████╗
╚════██║    ██║    ██╔══██║    ██║    ╚════██║
███████║    ██║    ██║  ██║    ██║    ███████║
╚══════╝    ╚═╝    ╚═╝  ╚═╝    ╚═╝    ╚══════╝
```

**A modern, zero-dependency terminal dashboard for real-time system monitoring**  
*Built for developers, sysadmins, and DevOps engineers who want answers fast.*

<br>

[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-0d1117?style=for-the-badge&logo=linux&logoColor=58a6ff&labelColor=161b22)](https://github.com/gouravroy27/Server-Stats#-linux--macos--wsl)
[![Bash](https://img.shields.io/badge/bash-4.0%2B-0d1117?style=for-the-badge&logo=gnu-bash&logoColor=58a6ff&labelColor=161b22)](https://github.com/gouravroy27/Server-Stats/blob/main/server-stats.sh)
[![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-0d1117?style=for-the-badge&logo=powershell&logoColor=58a6ff&labelColor=161b22)](https://github.com/gouravroy27/Server-Stats/blob/main/server-stats.ps1)
[![License](https://img.shields.io/badge/license-MIT-0d1117?style=for-the-badge&logoColor=58a6ff&labelColor=161b22)](https://github.com/gouravroy27/Server-Stats/blob/main/LICENSE)
[![Zero Deps](https://img.shields.io/badge/dependencies-zero-0d1117?style=for-the-badge&logoColor=58a6ff&labelColor=161b22)](https://github.com/gouravroy27/Server-Stats#-architecture-highlights)

<br>

</div>

---

## ▌ What Is Server Stats?

Server Stats is a **single-file, zero-dependency system monitoring tool** that renders a full performance dashboard right inside your terminal — no daemons, no background agents, no bloat. Built around a *Modern Minimalist Dashboard* design (Nord / Tokyo Night inspired), it gives you visual load gauges, interactive process lists, and live system metrics on demand.

Run it once for a health check, pipe it in scripts, or leave it looping — it works either way.

---

## ▌ Feature Matrix

| Feature | `server-stats.sh` | `server-stats.ps1` | Parity |
| :--- | :---: | :---: | :---: |
| CPU Load & Visual Gauges | ✦ | ✦ | 100% |
| Memory Allocation & Gauges | ✦ | ✦ | 100% |
| Per-Filesystem Disk Usage | ✦ | ✦ | 100% |
| Top 5 CPU-Consuming Processes | ✦ | ✦ | 100% |
| Top 5 Memory-Consuming Processes | ✦ | ✦ | 100% |
| Uptime & OS Details | ✦ | ✦ | 100% |
| Active Login Sessions | ✦ | ✦ | 100% |
| Failed Logon Attempt Count | ✦ `lastb` | ✦ Security Log | Admin req. on Windows |
| Battery Level & Charge Status | ✦ | ✦ | Laptops only |
| Hidden / Background Processes | ✦ | ✦ | 100% |
| Interactive Process Killing (PID) | ✦ | ✦ | 100% |
| Wi-Fi Hotspot Scanning | ✦ | ✦ | 100% |
| Current Wi-Fi Link Diagnostics | ✦ | ✦ | 100% |
| Wi-Fi Network Profile Connection | ✦ | ✦ | 100% |
| Full All-Stats Report (`-a / -All`) | ✦ | ✦ | 100% |

---

## ▌ Quick Install

### Clone the Repository

```bash
git clone https://github.com/gouravroy27/Server-Stats.git
cd Server-Stats
```

---

## ▌ Linux · macOS · WSL

### Requirements

| Tool | Purpose |
|------|---------|
| `bash 4.0+` | Shell runtime |
| `awk`, `sed`, `grep`, `ps`, `df` | Core POSIX metrics |
| `free` *(Linux)* · `vm_stat` *(macOS)* | Memory stats |
| `nmcli` or `iw` *(optional)* | Wi-Fi scanning |
| `acpi` or `/sys/class/power_supply` *(optional)* | Battery status |

Verify bash version: `bash --version`

### Setup & Run for linux 

```bash
# Step 1 — Clone
git clone https://github.com/gouravroy27/Server-Stats.git
cd Server-Stats

# Step 2 — Grant execute permission
chmod +x server-stats.sh

# Step 3 — Run
./server-stats.sh

# Optional: install system-wide
sudo cp server-stats.sh /usr/local/bin/server-stats
server-stats   # run from anywhere
```

### Command-Line Flags

```bash
./server-stats.sh           # Launch interactive dashboard
./server-stats.sh -h        # Show help and exit
./server-stats.sh -a        # Print full stats report and exit
./server-stats.sh --kill <PID>              # Kill process interactively
./server-stats.sh --wifi-list               # Scan and list nearby Wi-Fi networks
./server-stats.sh --wifi-current            # Show current Wi-Fi connection
./server-stats.sh --wifi-connect <SSID> [password]   # Connect to a network
```

### Diagnostics

```bash
vmstat 1 2                                      # CPU metrics check
free -b                                         # Memory check (Linux)
df -h                                           # Disk check
nmcli -t -f ACTIVE,SSID device wifi            # Wi-Fi check
cat /sys/class/power_supply/BAT0/capacity      # Battery check
```

---

## ▌ Windows 10 · 11

### Requirements

| Tool | Version |
|------|---------|
| Windows OS | Windows 10 Build 1809+ or Windows 11 |
| PowerShell | 5.1 (built-in) or Core 7+ *(recommended)* |
| WLAN AutoConfig Service | Required for Wi-Fi scanning |
| Admin rights | Only for failed logins log or kill restricted processes |

> **Recommended:** Run inside [Windows Terminal](https://aka.ms/terminal) with PowerShell Core 7+ for proper UTF-8 and ANSI rendering.

### Setup — Recommended (Batch Launcher)

No execution policy changes needed.

```batch
:: Step 1 — Clone via PowerShell or Git Bash
git clone https://github.com/gouravroy27/Server-Stats.git
cd Server-Stats

:: Step 2 — Unblock the script
::   Right-click server-stats.ps1 → Properties → ☑ Unblock → OK

:: Step 3 — Run
.\server-stats.bat
```

If you don't have the `.bat` launcher, create it manually in the same folder as the `.ps1`:

```batch
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server-stats.ps1" %*
```

Then double-click `server-stats.bat` — done.

### Setup — Alternative (Direct PowerShell)

```powershell
# Clone
git clone https://github.com/gouravroy27/Server-Stats.git
cd Server-Stats

# Allow local scripts (run PowerShell as Administrator once)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Run
.\server-stats.ps1
```

### Command-Line Parameters

```powershell
.\server-stats.ps1                              # Launch interactive dashboard
.\server-stats.ps1 -Help                        # Show help and exit
.\server-stats.ps1 -All                         # Print full stats report and exit
.\server-stats.ps1 -Kill <PID>                  # Kill process interactively
.\server-stats.ps1 -WifiList                    # Scan nearby Wi-Fi networks
.\server-stats.ps1 -WifiCurrent                 # Show current Wi-Fi connection
.\server-stats.ps1 -WifiConnect <SSID> [-WifiPassword <pass>]   # Connect to network
```

### Diagnostics

```powershell
Get-Process                                          # Process query check
Get-CimInstance -ClassName Win32_OperatingSystem     # WMI/CIM check
netsh wlan show interfaces                           # Wi-Fi interface check
Get-CimInstance Win32_Battery                        # Battery presence check
```

---

## ▌ Project Structure

```
Server-Stats/
├── server-stats.sh       ← Bash script  (Linux / macOS / WSL)
├── server-stats.ps1      ← PowerShell script  (Windows)
├── server-stats.bat      ← Batch launcher  (Windows, no policy changes needed)
└── README.md
```

---

## ▌ Troubleshooting

<details>
<summary><b>❯ "No such file or directory"</b></summary>

You're not in the right folder. Run `ls` to check, then `cd Server-Stats` and try again. Or run with a full path: `bash ./server-stats.sh`.

</details>

<details>
<summary><b>❯ "Permission denied" on Linux/macOS</b></summary>

```bash
chmod +x server-stats.sh
```

</details>

<details>
<summary><b>❯ "Wrong system configuration" — script exits</b></summary>

You selected Linux (1) on Windows or vice versa. Re-run and choose the option that matches your actual OS. WSL counts as **Linux**.

</details>

<details>
<summary><b>❯ Wi-Fi list is empty on Linux</b></summary>

NetworkManager may not be running.

```bash
systemctl status NetworkManager
sudo apt install network-manager iw    # Ubuntu/Debian
nmcli dev wifi                         # Validate
```

</details>

<details>
<summary><b>❯ Kill process returns "not found" or permission error</b></summary>

The PID may no longer exist, or it's a system process. Check active PIDs with menu option `08`, then relaunch with `sudo` (Linux) or **Run as Administrator** (Windows).

</details>

<details>
<summary><b>❯ PowerShell script won't run on Windows</b></summary>

Use the `.bat` launcher — it bypasses execution policy automatically. Or as Administrator:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

</details>

<details>
<summary><b>❯ "No battery detected"</b></summary>

Expected on desktops or inside virtual machines. No action needed.

</details>

---

## ▌ Architecture Highlights

**Bash (`server-stats.sh`)**
— Dual-texture gauge bars built with `awk` (24-char `█` / `░` display)  
— Severity coloring: Crimson ≥85% · Amber ≥60% · Green <60%  
— Modern left-accent card renderer using `▌` pillar prefix  
— OS auto-detection: Linux · WSL · macOS · Windows  
— Memory via `free -b` (Linux) or `vm_stat` (macOS)  
— Hidden process detection via `ps` TTY `?` filter  
— Wi-Fi via `nmcli` with `iw` fallback  

**PowerShell (`server-stats.ps1`)**
— Pure WMI/CIM — no third-party packages  
— CPU via `Win32_Processor`, Memory via `Win32_OperatingSystem`  
— Disk via `Win32_LogicalDisk`, Battery via `Win32_Battery`  
— Wi-Fi via `netsh.exe` with XML profile injection for connections  
— Failed logins via Windows Security Event Log (Event ID 4625)  
— Visual parity with Bash version: same gauges, same card style  

---

## ▌ Contributing

```bash
# Fork → clone → branch → push → PR

git checkout -b feature/your-feature-name
git commit -m "feat: describe your change"
git push origin feature/your-feature-name
```

Bug reports and feature requests are welcome via [Issues](https://github.com/gouravroy27/Server-Stats/issues).

---

## ▌ Credits & License

**License:** MIT — free to use, modify, and distribute.  
**Created:** July 5, 2026  
**Author:** [gourav-roy](https://github.com/gouravroy27)  
**Inspired by:** `btop` · `lazygit` · `k9s` — and the Nord & Tokyo Night terminal aesthetics.

---

<div align="center">

*If Server Stats saved you time, a ⭐ on the repo goes a long way.*

**[⭐ Star on GitHub](https://github.com/gouravroy27/Server-Stats)**

</div>
