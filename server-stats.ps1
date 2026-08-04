#Requires -Version 5.1
<#
.SYNOPSIS
    server-stats.ps1 - Modern Minimalist Dashboard (Windows)

.DESCRIPTION
    A pure PowerShell counterpart to server-stats.sh.
    Aesthetics: Tokyo Night / Nord Minimalist
    Architecture: Asymmetrical Left-Accent Cards
#>

[CmdletBinding()]
param(
    [switch]$All,
    [int]$Kill,
    [switch]$WifiList,
    [switch]$WifiCurrent,
    [string]$WifiConnect,
    [string]$WifiPassword,
    [switch]$Help
)

# =====================================================================
# Visual Constants & Colors (Using [char]27 for perfect backward compatibility)
# =====================================================================
$esc     = [char]27
$RESET   = "$esc[0m"
$BOLD    = "$esc[1m"
$DIM     = "$esc[2m"
$WHITE   = "$esc[97m"
$VIOLET  = "$esc[95m"
$MAGENTA = "$esc[95m"
$CYAN    = "$esc[96m"
$BLUE    = "$esc[34m"
$BRIGHT_BLUE = "$esc[94m"
$TEAL    = "$esc[36m"
$GREEN   = "$esc[32m"
$AMBER   = "$esc[33m"
$CRIMSON = "$esc[31m"
$GRAY    = "$esc[90m"

# =====================================================================
# Layout Engine
# =====================================================================

# Dual-Texture Gauge: Active (█) and Empty (░)
function Get-GaugeString([double]$val) {
    $width = 24
    $filled = [math]::Floor(($val / 100) * $width)
    if ($filled -gt $width) { $filled = $width }
    if ($filled -lt 0) { $filled = 0 }
    
    $res = ""
    for ($i = 0; $i -lt $filled; $i++) { $res += "█" }
    for ($i = $filled; $i -lt $width; $i++) { $res += "░" }
    return $res
}

# Dynamic threshold colors
function Get-GaugeColor([double]$val) {
    if ($val -ge 85) { return $CRIMSON }
    if ($val -ge 60) { return $AMBER }
    return $GREEN
}

function Draw-Banner {
    $line = "$BRIGHT_BLUE" + ("=" * 58) + "$RESET"
    Write-Host ("$line")
    Write-Host ("$MAGENTA$BOLD      SERVER PERFORMANCE DASHBOARD      $RESET")
    Write-Host ("$line")
}

function Draw-Snapshot {
    $hostName = hostname
    try {
        $osName = (Get-CimInstance Win32_OperatingSystem).Caption
    } catch {
        $osName = "Windows"
    }
    $dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host ("$BLUE  $hostName$RESET $GRAY| $RESET$BRIGHT_BLUE$osName$RESET $GRAY| $RESET$DIM$dateStr$RESET")
    Write-Host ""
}

function Draw-MainMenu {
    Write-Host ("$VIOLET$BOLD◆ MAIN MENU$RESET $GRAY──────────────────────────────────────────$RESET")
    Write-Host ("$CYAN▌$RESET  01  CPU Metrics        $CYAN▌$RESET  02  Memory Stats")
    Write-Host ("$CYAN▌$RESET  03  Disk Usage         $CYAN▌$RESET  04  Top CPU Processes")
    Write-Host ("$CYAN▌$RESET  05  Top Mem Processes   $CYAN▌$RESET  06  System Information")
    Write-Host ("$CYAN▌$RESET  07  Battery Status      $CYAN▌$RESET  08  Hidden Processes")
    Write-Host ("$CYAN▌$RESET  09  Wi-Fi List          $CYAN▌$RESET  10  Wi-Fi Current")
    Write-Host ("$CYAN▌$RESET  11  Full Report         $CYAN▌$RESET  00  Exit")
    Write-Host ("$GRAY──────────────────────────────────────────────────────────$RESET")
    Write-Host ("$DIM  › Select [1-11]   › Refresh [r]   › Exit [0]$RESET")
}

function Render-Panel([string]$title, [string]$content, [string]$icon="🧠") {
    Write-Host ""
    Write-Host ("$VIOLET$BOLD◆ $icon $title$RESET $GRAY──────────────────────────────────────────$RESET")
    
    $lines = $content -split "`n"
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        Write-Host ("$CYAN▌$RESET  $line")
    }
    Write-Host ""
}

# =====================================================================
# OS Selection Prompt
# =====================================================================
function Invoke-OsSelectionPrompt {
    Write-Host "Which system are you using?"
    Write-Host "  1. Linux"
    Write-Host "  2. Windows"
    $choice = Read-Host "Enter your choice (1 or 2)"

    $selected = switch -Regex ($choice) {
        '^(1|[Ll]inux)$'   { "linux";   break }
        '^(2|[Ww]indows)$' { "windows"; break }
        default            { $null }
    }

    if (-not $selected) {
        Write-Host "Invalid choice."
        exit 1
    }

    if ($selected -ne "windows") {
        Write-Host "Error: Wrong system configuration."
        exit 1
    }
}

# =====================================================================
# Metric Gathering Logic
# =====================================================================

function Get-CpuUsage {
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        if ($null -ne $cpu) {
            $gauge = Get-GaugeString $cpu
            $color = Get-GaugeColor $cpu
            return "${WHITE}Usage:${RESET}  $color$gauge$RESET $color$([math]::Round($cpu, 2))%$RESET"
        }
    } catch {}
    return "CPU Usage: N/A"
}

function Get-MemUsage {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)
        $freeMB  = [math]::Round($os.FreePhysicalMemory / 1KB, 0)
        $usedMB  = $totalMB - $freeMB
        $usedPct = if ($totalMB -gt 0) { [math]::Round(($usedMB * 100.0) / $totalMB, 2) } else { 0 }
        
        $gauge = Get-GaugeString $usedPct
        $color = Get-GaugeColor $usedPct
        
        $out = "${WHITE}Usage:${RESET}  $color$gauge$RESET $color$([math]::Round($usedPct, 2))%$RESET`n"
        $out += "${WHITE}Stats:${RESET}  $TEAL$usedMB MB used$RESET $GRAY/ $RESET$TEAL$freeMB MB free$RESET $DIM(Total: $totalMB MB)$RESET"
        return $out
    } catch { return "Memory Usage: N/A" }
}

function Get-DiskUsage {
    $out = "$WHITE{0,-8} {1,-12} {2,-12} {3,-12} {4}$RESET" -f "Drive", "Size", "Used", "Free", "Use%"
    try {
        Get-CimInstance Win32_LogicalDisk | Where-Object { $_.Size -gt 0 } | ForEach-Object {
            $sizeGB = [math]::Round($_.Size / 1GB, 1)
            $freeGB = [math]::Round($_.FreeSpace / 1GB, 1)
            $usedGB = [math]::Round($sizeGB - $freeGB, 1)
            $usedPct = if ($sizeGB -gt 0) { [math]::Round(($usedGB * 100.0) / $sizeGB, 0) } else { 0 }
            $out += "`n$GRAY{0,-8}$RESET $WHITE{1,-12} {2,-12} {3,-12}$RESET $TEAL{4}%$RESET" -f $_.DeviceID, "${sizeGB}G", "${usedGB}G", "${freeGB}G", $usedPct
        }
    } catch { return "Disk Usage: N/A" }
    return $out
}

function Get-TopCpu {
    $out = "$WHITE{0,-8} {1,-25} {2,-15} {3}$RESET" -f "PID", "COMMAND", "CPU(secs)", "STARTED"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
        $started = try { $_.StartTime.ToString("HH:mm:ss") } catch { "N/A" }
        $out += "`n$GRAY{0,-8}$RESET $WHITE{1,-25}$RESET $TEAL{2,-15}$RESET $GRAY{3}$RESET" -f $_.Id, $_.ProcessName, [math]::Round($_.CPU, 2), $started
    }
    return $out
}

function Get-TopMem {
    $out = "$WHITE{0,-8} {1,-25} {2,-15} {3}$RESET" -f "PID", "COMMAND", "WS(MB)", "STARTED"
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | ForEach-Object {
        $started = try { $_.StartTime.ToString("HH:mm:ss") } catch { "N/A" }
        $wsMB = [math]::Round($_.WorkingSet / 1MB, 2)
        $out += "`n$GRAY{0,-8}$RESET $WHITE{1,-25}$RESET $TEAL{2,-15}$RESET $GRAY{3}$RESET" -f $_.Id, $_.ProcessName, $wsMB, $started
    }
    return $out
}

function Get-ExtraStats {
    $out = ""
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $out += "${WHITE}OS:${RESET}      $TEAL$($os.Caption) (Version $($os.Version))$RESET`n"
        $uptimeSpan = (Get-Date) - $os.LastBootUpTime
        $out += "${WHITE}Uptime:${RESET}   $TEAL$($uptimeSpan.Days)d $($uptimeSpan.Hours)h $($uptimeSpan.Minutes)m$RESET`n"
    } catch { $out += "${WHITE}OS:${RESET}      ${TEAL}N/A$RESET`n" }

    try {
        $users = (Get-CimInstance Win32_LogonSession | Where-Object { $_.LogonType -eq 2 -or $_.LogonType -eq 10 } | Measure-Object).Count
        $out += "${WHITE}Users:${RESET}    $TEAL$users user(s)$RESET`n"
    } catch { $out += "${WHITE}Users:${RESET}    ${TEAL}N/A$RESET`n" }

    try {
        $fails = (Get-WinEvent -FilterHashtable @{LogName = "Security"; Id = 4625 } -MaxEvents 50 -ErrorAction Stop | Measure-Object).Count
        $out += "${WHITE}Failed:${RESET}   $AMBER$fails$RESET"
    } catch { $out += "${WHITE}Failed:${RESET}   $GRAYN/A (Run as Admin)$RESET" }
    
    return $out
}

function Get-BatteryStatus {
    try {
        $bat = Get-CimInstance Win32_Battery -ErrorAction Stop
        if (-not $bat) { return "No battery detected" }
        $level = $bat.EstimatedChargeRemaining
        $gauge = Get-GaugeString $level
        $color = Get-GaugeColor $level
        
        $out = "${WHITE}Level:${RESET}  $color$gauge$RESET $color$level%$RESET`n"
        switch ($bat.BatteryStatus) {
            1 { $out += "${WHITE}Status:${RESET}  ${TEAL}Discharging$RESET" }
            2 { $out += "${WHITE}Status:${RESET}  ${TEAL}Charging$RESET" }
            3 { $out += "${WHITE}Status:${RESET}  ${TEAL}Fully Charged$RESET" }
            4 { $out += "${WHITE}Status:${RESET}  ${AMBER}Low$RESET" }
            5 { $out += "${WHITE}Status:${RESET}  ${CRIMSON}Critical$RESET" }
            default { $out += "${WHITE}Status:${RESET}  ${GRAY}Unknown$RESET" }
        }
        return $out
    } catch { return "No battery detected" }
}

function Get-HiddenProcesses {
    $out = "$WHITE{0,-8} {1,-25} {2}$RESET" -f "PID", "COMMAND", "SESSION"
    Get-Process | Where-Object { $_.MainWindowTitle -eq "" } | Select-Object -First 15 | ForEach-Object {
        $out += "`n$GRAY{0,-8}$RESET $WHITE{1,-25}$RESET $GRAY{2}$RESET" -f $_.Id, $_.ProcessName, $_.SessionId
    }
    return $out
}

function Invoke-KillProcess([int]$pid_) {
    try {
        $proc = Get-Process -Id $pid_ -ErrorAction Stop
    } catch {
        Write-Host "$RED[Error] Process $pid_ does not exist.$RESET"
        return 1
    }
    Write-Host ("$WHITEProcess found:$RESET  $GRAY$pid_$RESET | $WHITE$($proc.ProcessName)$RESET")
    $answer = Read-Host "  Kill this process? [y/N]"
    if ($answer -match '^[yY]') {
        try {
            Stop-Process -Id $pid_ -Force -ErrorAction Stop
            Write-Host "$GREEN[Success] Process terminated.$RESET"
            return 0
        } catch {
            Write-Host "$RED[Error] Failed to kill PID $pid_.$RESET"
            return 1
        }
    }
    Write-Host "$GRAY[Aborted]$RESET"
    return 0
}

function Get-WifiList {
    $out = ""
    $raw = netsh wlan show networks mode=bssid 2>$null
    if (-not $raw) { return "Error: No Wi-Fi adapter found." }
    $out += "$WHITE{0,-32} {1,-15} {2}$RESET" -f "SSID", "AUTH", "SIGNAL"
    $ssid = $null; $auth = "--"
    foreach ($line in $raw) {
        if ($line -match '^SSID\s+\d+\s+:\s*(.*)$') { $ssid = $matches[1].Trim() }
        elseif ($line -match '^\s*Authentication\s*:\s*(.*)$') { $auth = $matches[1].Trim() }
        elseif ($line -match '^\s*Signal\s*:\s*(.*)$') {
            $signal = $matches[1].Trim()
            if ($ssid) { 
                $out += "`n$WHITE{0,-32}$RESET $TEAL{1,-15}$RESET $GRAY{2}$RESET" -f $ssid, $auth, $signal 
            }
        }
    }
    return $out
}

function Get-WifiCurrent {
    $raw = netsh wlan show interfaces 2>$null
    if (-not $raw) { return "Error: No Wi-Fi adapter found." }
    $ssidLine = $raw | Select-String '^\s*SSID\s*:\s*(.*)$' | Select-Object -First 1
    $stateLine = $raw | Select-String '^\s*State\s*:\s*(.*)$' | Select-Object -First 1
    if ($stateLine -and $stateLine.Matches[0].Groups[1].Value.Trim() -eq "connected") {
        return "${WHITE}SSID:${RESET}  $TEAL$($ssidLine.Matches[0].Groups[1].Value.Trim())$RESET"
    }
    return "Not connected to any Wi-Fi network."
}

function Invoke-WifiConnect([string]$ssid, [string]$password) {
    if (-not $ssid) { Write-Host "$RED[Error] SSID required.$RESET"; return 1 }
    if (-not $password) {
        $secure = Read-Host "  Enter password for '$ssid'" -AsSecureString
        $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    }
    $profileXml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$ssid</name>
    <SSIDConfig><SSID><name>$ssid</name></SSID></SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>manual</connectionMode>
    <MSM><security><authEncryption><authentication>WPA2PSK</authentication><encryption>AES</encryption><useOneX>false</useOneX></authEncryption><sharedKey><keyType>passPhrase</keyType><protected>false</protected><keyMaterial>$password</keyMaterial></sharedKey></security></MSM>
</WLANProfile>
"@
    $xmlPath = Join-Path ([System.IO.Path]::GetTempPath()) "wifi_temp_$(Get-Random).xml"
    $profileXml | Out-File -FilePath $xmlPath -Encoding UTF8
    netsh wlan add profile filename="$xmlPath" user=current 2>&1 | Out-Null
    Remove-Item $xmlPath -ErrorAction SilentlyContinue
    netsh wlan connect name="$ssid" 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    $state = (netsh wlan show interfaces 2>$null) | Select-String '^\s*State\s*:\s*connected'
    if ($state) { 
        Write-Host "$GREEN[Success] Successfully connected to $ssid.$RESET"
        return 0 
    }
    Write-Host "$RED[Error] Failed to connect to $ssid.$RESET"
    return 1
}

# =====================================================================
# Help & Main Argument Dispatch
# =====================================================================
if ($Help) {
    Write-Host "Usage: server-stats.ps1 [OPTIONS]"
    Write-Host "  -All                        Show hidden/background processes"
    Write-Host "  -Kill <PID>                 Kill specified PID"
    Write-Host "  -WifiList                   List Wi-Fi networks"
    Write-Host "  -WifiCurrent                Show current Wi-Fi"
    Write-Host "  -WifiConnect <SSID> [-WifiPassword <password>]"
    exit 0
}

Invoke-OsSelectionPrompt

if ($WifiList) { Render-Panel "Wi-Fi List" (Get-WifiList) "📶"; exit 0 }
if ($WifiCurrent) { Render-Panel "Wi-Fi Current" (Get-WifiCurrent) "🌐"; exit 0 }
if ($WifiConnect) { exit (Invoke-WifiConnect -ssid $WifiConnect -password $WifiPassword) }
if ($Kill -gt 0) { exit (Invoke-KillProcess -pid_ $Kill) }

# =====================================================================
# Interactive TUI Loop
# =====================================================================
while ($true) {
    Clear-Host
    Draw-Banner
    Draw-Snapshot
    Draw-MainMenu
    
    $choice = (Read-Host "  Selection").Trim()
    Write-Host ""
    
    switch ($choice) {
        '1'  { Render-Panel "CPU Usage" (Get-CpuUsage) "⚙️" }
        '2'  { Render-Panel "Memory Usage" (Get-MemUsage) "🧠" }
        '3'  { Render-Panel "Disk Usage" (Get-DiskUsage) "💾" }
        '4'  { Render-Panel "Top 5 CPU Processes" (Get-TopCpu) "⚡" }
        '5'  { Render-Panel "Top 5 Memory Processes" (Get-TopMem) "📊" }
        '6'  { Render-Panel "System Information" (Get-ExtraStats) "ℹ️" }
        '7'  { Render-Panel "Battery Status" (Get-BatteryStatus) "🔋" }
        '8'  { Render-Panel "Hidden Processes" (Get-HiddenProcesses) "👻" }
        '9'  { Render-Panel "Wi-Fi List" (Get-WifiList) "📶" }
        '10' { Render-Panel "Wi-Fi Current" (Get-WifiCurrent) "🌐" }
        '11' {
            Render-Panel "CPU Usage" (Get-CpuUsage) "⚙️"
            Render-Panel "Memory Usage" (Get-MemUsage) "🧠"
            Render-Panel "Disk Usage" (Get-DiskUsage) "💾"
            Render-Panel "Top CPU" (Get-TopCpu) "⚡"
            Render-Panel "Top Mem" (Get-TopMem) "📊"
            Render-Panel "System Info" (Get-ExtraStats) "ℹ️"
            Render-Panel "Battery" (Get-BatteryStatus) "🔋"
            if ($All) { Render-Panel "Hidden" (Get-HiddenProcesses) "👻" }
        }
        '0'  { Write-Host "Exiting..."; exit 0 }
        'r'  { continue }
        default { }
    }
    $null = Read-Host "  Press Enter to return to menu..."
}
