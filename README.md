<div align="center">

<img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue?style=for-the-badge&logo=linux&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/shell-bash%204.0%2B-green?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
<img src="https://img.shields.io/badge/powershell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell">
<img src="https://img.shields.io/badge/license-MIT-orange?style=for-the-badge" alt="License">

# 📊 Server Stats

**A powerful, lightweight cross-platform system monitoring tool**  
*Real-time visibility into every process running on your machine — from CPU hogs to memory leaks.*

[Getting Started](#-getting-started) · [Linux / macOS](#-linux--macos--wsl) · [Windows](#-windows-10--11) · [Features](#-features) · [Contributing](#-contributing)

---

</div>

## ✨ Features

- 🔍 **Process Monitoring** — View stats for all running processes in real time
- 💾 **Memory Usage** — Track RAM consumption system-wide and per process
- ⚡ **CPU Metrics** — Identify CPU-hungry processes instantly
- 🛜 **Wi-Fi Info** — Optional network interface status (Linux/macOS)
- 🔋 **Battery Status** — Optional battery reporting on supported systems
- 🪟 **Cross-Platform** — Works on Linux, macOS, WSL2, Windows 10 & 11
- 🪶 **Zero Dependencies** — Uses only standard POSIX utilities

---

## 🚀 Getting Started

Choose your platform below and follow the steps to get up and running in under a minute.

---

## 🐧 Linux / macOS / WSL

### Supported Platforms

| Platform | Version |
|----------|---------|
| Linux | Kernel 2.6+ (any distro) |
| macOS | 10.9 Mavericks and above |
| Windows WSL2 | Ubuntu / Debian subsystem |

### Required Dependencies

These are standard POSIX utilities — they come pre-installed on virtually every Unix-like system.

```
bash (4.0+)   awk   sed   grep   ps
free (Linux)  OR  vm_stat (macOS)
```

### Installation & Usage

```bash
# 1. Download the script
curl -O https://raw.githubusercontent.com/your-username/server-stats/main/server-stats.sh

# 2. Make it executable
chmod +x server-stats.sh

# 3. Run it
./server-stats.sh
```

### Optional Dependencies

For extended features, you can optionally install:

| Feature | Tool |
|---------|------|
| Wi-Fi management | `nmcli` or `iw` |
| Battery status | `acpi` or `/sys/class/power_supply/` |

```bash
# Ubuntu / Debian
sudo apt install acpi network-manager

# Arch Linux
sudo pacman -S acpi networkmanager
```

---

## 🪟 Windows 10 / 11

### Supported Platforms

| Platform | Build |
|----------|-------|
| Windows 10 | Build 1809 and above |
| Windows 11 | All builds |

### Required Dependencies

| Tool | Version |
|------|---------|
| PowerShell | 5.1 (built-in) or Core 7+ *(recommended)* |

### ✅ Recommended Method — Batch Launcher

No system-wide policy changes needed. Just use the included launcher:

```
1. Place server-stats.ps1 and server-stats.bat in the same folder.

2. Unblock the script:
   Right-click server-stats.ps1 → Properties → ☑ Unblock → OK

3. Run it:
   Double-click server-stats.bat
   — OR —
   From CMD: .\server-stats.bat
```

### ⚙️ Alternative — Direct PowerShell (Advanced Users)

If you prefer running the `.ps1` directly, you'll need to adjust the execution policy first:

```powershell
# Open PowerShell as Administrator, then run:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Then run the script:
.\server-stats.ps1
```

> **Note:** Only modify execution policy if you understand the security implications.  
> The batch launcher method is recommended for most users.

---

## 📁 Project Structure

```
server-stats/
├── server-stats.sh       # Main script for Linux / macOS / WSL
├── server-stats.ps1      # PowerShell script for Windows
├── server-stats.bat      # Batch launcher for Windows (no policy changes needed)
└── README.md
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ — if this helped you, consider giving it a ⭐

</div>
