# SERVER STATS — System Monitoring Tool (Bash/PowerShell)

## SECTION 1: PROJECT OVERVIEW

The **Server Stats System Monitoring Tool** is a lightweight, high-fidelity real-time system statistics viewer designed for on-demand performance reporting. It allows administrators, developers, and DevOps engineers to perform instant system health checks without the overhead of heavy daemon processes or continuous background agents. The tool provides a unified user interface on both Unix-like and Windows platforms, giving users standard metric tables, interactive lists, and visual resource load gauges directly in their terminal.

### Key Architectural Design
- **Single-File Zero-Dependency (sh):** On Linux, macOS, and WSL, the Bash script requires only standard POSIX shell tools.
- **Native PowerShell Integration (ps1):** On Windows, the PowerShell script leverages the native Windows Management Instrumentation (WMI / CIM) framework.
- **Aesthetic Overhaul:** Built around a modern, minimalist dashboard style utilizing clean terminal formatting.

---

## SECTION 2: INSTALLATION & SETUP

### Subsection 2A: Linux / macOS / WSL (server-stats.sh)

#### Installation Steps
1. **Download:** Place `server-stats.sh` in your working directory.
2. **Grant Execution Permissions:**
   ```bash
   chmod +x server-stats.sh
   ```
3. **Run:**
   ```bash
   ./server-stats.sh
   ```

---

### Subsection 2B: Windows 10 / 11 (server-stats.ps1)

#### Installation & Execution (Recommended)

To run the tool without modifying your PowerShell security settings:

1.  **Download:** Download `server-stats.ps1` and `server-stats.bat` from this repository and place them in the same directory.
2.  **Unblock Files:**
    - Right-click `server-stats.ps1`, select **Properties**.
    - Check **Unblock** and click **OK**.
    - Do the same for `server-stats.bat`.
3.  **Run:** Simply double-click `server-stats.bat` or run it from CMD/PowerShell:
    ```cmd
    .\server-stats.bat
    ```

*Note: The batch file uses `powershell -ExecutionPolicy Bypass` to allow the script to run securely without changing global policies.*

---

## SECTION 3: USAGE — COMMAND-LINE REFERENCE

### Linux/Bash
```bash
bash server-stats.sh [OPTIONS]
```
- Interactive: Run without arguments.
- Scriptable: `-a` (All stats), `--kill <PID>`, `--wifi-list`, `--wifi-current`

### Windows/PowerShell
```powershell
.\server-stats.bat [OPTIONS]
```
- Interactive: Run `.\server-stats.bat`
- Scriptable: `-All`, `-Kill <PID>`, `-WifiList`, `-WifiCurrent`, `-WifiConnect <SSID> [-WifiPassword <password>]`

---

## SECTION 4: TROUBLESHOOTING

- **Permission Denied (Linux):** Ensure you ran `chmod +x server-stats.sh`.
- **PowerShell Script Blocked (Windows):** Use the recommended `server-stats.bat` launcher. Ensure you have "Unblocked" the file in Properties.
- **Battery Info Missing:** This is normal on desktop computers without a physical battery.

---

## SECTION 5: LICENSE & CREDITS

- **License:** MIT License.
- **Created:** July 5, 2026.
- **Contributors:** [gouravroy27](https://github.com/gouravroy27)
