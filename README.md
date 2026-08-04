<div align="center">

# 🖥️ `[ SYSTEM.MONITORING.ONLINE ]`
### `root@gourav:~/Server-Stats$ ./run_dashboard.sh`

```text
  ___  ___  ___  ___  ____    ___  _____   _   _____  ___ 
 / __|| __|| _ \| _ \|  _ \  / __||_   _| /_\ |_   _|/ __|
 \__ \| _| |   /|   /| | | | \__ \  | |  / _ \  | |  \__ \
 |___/|___||_|_\|_|_\|_| |_| |___/  |_| /_/ \_\ |_|  |___/
```

[![Typing SVG](https://readme-typing-svg.herokuapp.com/?font=VT323&size=28&color=00FF00&center=true&vCenter=true&width=750&height=45&lines=Initialising+System+Diagnostics...;Status:+High_Fidelity_RealTime_Metrics;Architecture:+Zero-Dependency_Shell_PowerShell)](https://git.io/typing-svg)

<br>

![Bash](https://img.shields.io/badge/Bash-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

</div>

---

### 📁 `[ ./PROJECT_DESCRIPTION ]`

The **Server Stats** tool is a lightweight, high-fidelity system monitoring utility. No daemons, no heavy overhead. Just raw, real-time data directly in your terminal.

Whether you're debugging on a Linux server or checking hardware health on Windows, this dashboard provides everything you need with a modern aesthetic that doesn't hurt the eyes.

<div align="center">

![Dashboard Preview](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHZtamxjcndkcHl1dGFnZzkyejE3YWpkaDh6YW9leHhieDlzbHk3ciZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3ohc11UljvpPKWeNva/giphy.gif)

</div>

---

### 🚀 `[ ./FEATURES ]`

- **Bash/PowerShell Parity:** Native performance on both Linux and Windows.
- **Modern Minimalist UI:** Asymmetrical left-accent cards (`▌`).
- **Zero Dependencies:** Pure POSIX shell and WMI/CIM.
- **Features Include:** CPU/Memory Gauges, Disk Usage, Top Processes, Wi-Fi Diagnostics, and Battery Status.

---

### 🛠️ `[ ./INSTALLATION_&_EXECUTION ]`

#### 🐧 Linux / macOS / WSL
1. **Grant permissions:** `chmod +x server-stats.sh`
2. **Execute:** `./server-stats.sh`

#### 🪟 Windows 10/11
1. **Download:** `server-stats.ps1` and `server-stats.bat`.
2. **Unblock:** Right-click both files -> Properties -> Check **Unblock** -> OK.
3. **Run:** Double-click `server-stats.bat`.

*Note: The included batch launcher bypasses execution policy restrictions without compromising system security.*

---

### 🧬 `[ ./CODE_ARCHITECTURE ]`

<details>
<summary><b><code>>_ click_to_expand_internal_logic</code></b></summary>

<br>

How the magic happens under the hood:

```text
📦 Server-Stats
 ┣ 📜 server-stats.sh    # Bash core logic (awk/sed/grep)
 ┣ 📜 server-stats.ps1   # PowerShell core (WMI/CIM)
 ┣ 📜 server-stats.bat   # Windows execution wrapper
 ┗ 📜 requirements.txt   # Env diagnostics guide
```

</details>

<br>

<div align="center">

![System Check](https://media.giphy.com/media/T9lEUmQx0u74G3gZ5c/giphy.gif)

<br>
<code>[ SYSTEM_HEALTH: OPTIMAL ]</code><br>
<code>[ CONNECTION_TERMINATED ]</code>

</div>
