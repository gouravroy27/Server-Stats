#!/usr/bin/env bash
#
# server-stats.sh – Modern Minimalist Dashboard
#
# Aesthetics: Tokyo Night / Nord Minimalist
# Architecture: Asymmetrical Left-Accent Cards
#
set -uo pipefail

# =====================================================================
# Tokyo Night Color Palette
# =====================================================================
RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
WHITE=$'\e[97m'
VIOLET=$'\e[95m'
CYAN=$'\e[96m'
TEAL=$'\e[36m'
GREEN=$'\e[32m'
AMBER=$'\e[33m'
CRIMSON=$'\e[31m'
GRAY=$'\e[90m'

# =====================================================================
# Layout Engine
# =====================================================================

# Dual-Texture Gauge: Active (█) and Empty (░)
get_gauge_string() {
    local val="$1"
    awk -v v="$val" 'BEGIN {
        width = 24;
        filled = int((v / 100) * width);
        if (filled > width) filled = width;
        if (filled < 0) filled = 0;
        
        res = "";
        for (i=0; i<filled; i++) res = res "█";
        for (i=filled; i<width; i++) res = res "░";
        print res;
    }'
}

# Dynamic color based on thresholds
get_gauge_color() {
    local val="$1"
    awk -v v="$val" 'BEGIN {
        if (v >= 85) print "CRIMSON";
        else if (v >= 60) print "AMBER";
        else print "GREEN";
    }'
}

draw_banner() {
    local text="SERVER PERFORMANCE DASHBOARD"
    local line="──────────────────────────────────────────────────────────"
    echo -e "${GRAY}${line}${RESET}"
    printf "${VIOLET}${BOLD}  %s  ${RESET}
" "$text"
    echo -e "${GRAY}${line}${RESET}"
}

draw_snapshot() {
    local host=$(hostname)
    local os=$(uname -s)
    local date_str=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${DIM}  ${host}  ${os}  ${date_str}${RESET}"
    echo ""
}

draw_main_menu() {
    echo -e "${VIOLET}${BOLD}◆ MAIN MENU${RESET} ${GRAY}──────────────────────────────────────────${RESET}"
    echo -e "${CYAN}▌${RESET}  01  CPU Metrics        ${CYAN}▌${RESET}  02  Memory Stats"
    echo -e "${CYAN}▌${RESET}  03  Disk Usage         ${CYAN}▌${RESET}  04  Top CPU Processes"
    echo -e "${CYAN}▌${RESET}  05  Top Mem Processes   ${CYAN}▌${RESET}  06  System Information"
    echo -e "${CYAN}▌${RESET}  07  Battery Status      ${CYAN}▌${RESET}  08  Hidden Processes"
    echo -e "${CYAN}▌${RESET}  09  Wi-Fi List          ${CYAN}▌${RESET}  10  Wi-Fi Current"
    echo -e "${CYAN}▌${RESET}  11  Full Report         ${CYAN}▌${RESET}  00  Exit"
    echo -e "${GRAY}──────────────────────────────────────────────────────────${RESET}"
    echo -e "${DIM}  › Select [1-11]   › Refresh [r]   › Exit [0]${RESET}"
}

render_panel() {
    local title="$1"
    local content="$2"
    local icon="${3:-🧠}"
    
    echo -e "
${VIOLET}${BOLD}◆ ${icon} ${title}${RESET} ${GRAY}──────────────────────────────────────────${RESET}"
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        # Left accent pillar
        printf "${CYAN}▌${RESET}  %s
" "$line"
    done <<< "$content"
    echo ""
}

# =====================================================================
# OS Detection & Selection
# =====================================================================
os_type=""
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
                os_type="wsl"
            else
                os_type="linux"
            fi
            ;;
        Darwin*)               os_type="macos" ;;
        MINGW*|MSYS*|CYGWIN*)  os_type="windows" ;;
        *)                     os_type="linux" ;;
    esac
}
detect_os

actual_group="linux"
case "$os_type" in
    windows) actual_group="windows" ;;
    wsl)     actual_group="linux" ;;
    macos)   actual_group="macos" ;;
    *)       actual_group="linux" ;;
esac

selected_os=""
prompt_os_selection() {
    echo "Which system are you using?"
    echo "  1. Linux"
    echo "  2. Windows"
    read -rp "Enter your choice (1 or 2): " choice

    case "$choice" in
        1|[Ll]inux)   selected_os="linux" ;;
        2|[Ww]indows) selected_os="windows" ;;
        *)
            echo "Invalid choice."
            exit 1
            ;;
    esac

    if [[ "$selected_os" != "$actual_group" ]]; then
        echo "Error: Wrong system configuration."
        exit 1
    fi
}

# =====================================================================
# Cross-platform helpers
# =====================================================================
win_ps() {
    powershell.exe -NoProfile -NonInteractive -Command "$1" 2>/dev/null | tr -d ''
}

# =====================================================================
# Data Gathering Logic
# =====================================================================

linux_cpu_usage() {
    local idle used
    idle=$(vmstat 1 2 2>/dev/null | tail -1 | awk '{print $15}')
    if [[ -n "$idle" && "$idle" =~ ^[0-9]+$ ]]; then
        used=$(awk -v idle="$idle" 'BEGIN {printf "%.2f", 100-idle}')
    else
        local cpu user nice system idleT iowait irq softirq steal guest guest_nice
        cpu=$(grep '^cpu ' /proc/stat)
        read -r _ user nice system idleT iowait irq softirq steal guest guest_nice <<<"$cpu"
        local total=$((user+nice+system+idleT+iowait+irq+softirq+steal))
        used=$(awk -v idleT="$idleT" -v total="$total" 'BEGIN {printf "%.2f", (($total-idleT)*100)/total}')
    fi
    
    local gauge=$(get_gauge_string "$used")
    local color_name=$(get_gauge_color "$used")
    local color_var="${!color_name}"
    
    printf "${WHITE}Usage:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%.2f%%${RESET}
" "$used"
}

windows_cpu_usage() {
    local cpu
    cpu=$(win_ps '(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average')
    if [[ -n "$cpu" ]]; then
        local gauge=$(get_gauge_string "$cpu")
        local color_name=$(get_gauge_color "$cpu")
        local color_var="${!color_name}"
        printf "${WHITE}Usage:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%.2f%%${RESET}
" "$cpu"
    else
        echo "CPU Usage: N/A"
    fi
}

cpu_usage() {
    case "$os_type" in
        windows|wsl) windows_cpu_usage ;;
        *)           linux_cpu_usage  ;;
    esac
}

linux_mem_usage() {
    local mem total used free used_pct used_mb free_mb total_mb
    mem=$(free -b | awk '/Mem:/ {printf "%s %s %s
", $2, $3, $4}')
    read -r total used free <<<"$mem"
    used_mb=$((used/1024/1024))
    free_mb=$((free/1024/1024))
    total_mb=$((total/1024/1024))
    used_pct=$(awk -v used="$used" -v total="$total" 'BEGIN {printf "%.2f", ($used*100)/total}')
    
    local gauge=$(get_gauge_string "$used_pct")
    local color_name=$(get_gauge_color "$used_pct")
    local color_var="${!color_name}"
    
    printf "${WHITE}Usage:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%.2f%%${RESET}
" "$used_pct"
    printf "${WHITE}Stats:${RESET}  ${TEAL}%s MB used${RESET} ${GRAY} / ${RESET}${TEAL}%s MB free${RESET} ${DIM}(Total: %s MB)${RESET}
" "$used_mb" "$free_mb" "$total_mb"
}

windows_mem_usage() {
    local mem_info total_kb free_kb total_mb free_mb used_mb used_pct
    mem_info=$(win_ps '$os = Get-CimInstance Win32_OperatingSystem; Write-Output "$($os.TotalVisibleMemorySize) $($os.FreePhysicalMemory)"')
    read -r total_kb free_kb <<<"$mem_info"
    if [[ -n "$total_kb" && "$total_kb" -gt 0 ]]; then
        total_mb=$((total_kb / 1024))
        free_mb=$((free_kb / 1024))
        used_mb=$((total_mb - free_mb))
        used_pct=$(awk -v used_mb="$used_mb" -v total_mb="$total_mb" 'BEGIN {printf "%.2f", ($used_mb*100)/total_mb}')
        
        local gauge=$(get_gauge_string "$used_pct")
        local color_name=$(get_gauge_color "$used_pct")
        local color_var="${!color_name}"
        
        printf "${WHITE}Usage:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%.2f%%${RESET}
" "$used_pct"
        printf "${WHITE}Stats:${RESET}  ${TEAL}%s MB used${RESET} ${GRAY} / ${RESET}${TEAL}%s MB free${RESET} ${DIM}(Total: %s MB)${RESET}
" "$used_mb" "$free_mb" "$total_mb"
    else
        echo "Memory Usage: N/A"
    fi
}

mem_usage() {
    case "$os_type" in
        windows|wsl) windows_mem_usage ;;
        *)           linux_mem_usage  ;;
    esac
}

linux_disk_usage() {
    printf "${WHITE}%-20s %-10s %-10s %-10s %-s${RESET}
" "Filesystem" "Size" "Used" "Avail" "Use%"
    df -h --output=source,size,used,avail,pcent --exclude-type=tmpfs --exclude-type=devtmpfs | 
        tail -n +2 | while read -r fs size used avail pcent; do
            printf "${GRAY}%-20s ${WHITE}%-10s ${WHITE}%-10s ${WHITE}%-10s ${TEAL}%-s${RESET}
" "$fs" "$size" "$used" "$avail" "$pcent"
        done
}

windows_disk_usage() {
    printf "${WHITE}%-8s %-15s %-15s %-15s %-s${RESET}
" "Drive" "Size" "Used" "Free" "Use%"
    local output
    output=$(win_ps 'Get-CimInstance Win32_LogicalDisk | Where-Object { $_.Size -gt 0 } | ForEach-Object { Write-Output "$($_.DeviceID) $($_.Size) $($_.FreeSpace)" }')
    echo "$output" | while read -r drive size_bytes free_bytes; do
        [[ -z "$drive" ]] && continue
        local used_bytes=$((size_bytes - free_bytes))
        local used_pct=$(( used_bytes * 100 / size_bytes ))
        local size_gb=$((size_bytes / 1024 / 1024 / 1024))
        local used_gb=$((used_bytes / 1024 / 1024 / 1024))
        local free_gb=$((free_bytes / 1024 / 1024 / 1024))
        printf "${GRAY}%-8s ${WHITE}%-15s ${WHITE}%-15s ${WHITE}%-15s ${TEAL}%s%%${RESET}
" "$drive" "${size_gb}G" "${used_gb}G" "${free_gb}G" "$used_pct"
    done
}

disk_usage() {
    case "$os_type" in
        windows|wsl) windows_disk_usage ;;
        *)           linux_disk_usage  ;;
    esac
}

linux_top_cpu() {
    printf "${WHITE}%-8s %-20s %-8s %-s${RESET}
" "PID" "COMMAND" "%CPU" "TIME"
    ps -eo pid,comm,%cpu,etime --sort=-%cpu | head -n 6 | tail -n 5 | while read -r pid comm cpu time; do
        printf "${GRAY}%-8s ${WHITE}%-20s ${TEAL}%-8s ${GRAY}%-s${RESET}
" "$pid" "$comm" "$cpu" "$time"
    done
}

windows_top_cpu() {
    printf "${WHITE}%-8s %-25s %-15s %-s${RESET}
" "PID" "COMMAND" "CPU(secs)" "STARTED"
    local output
    output=$(win_ps 'Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Id, ProcessName, CPU, StartTime | ForEach-Object { "$($_.Id)|$($_.ProcessName)|$($_.CPU)|$($_.StartTime)" }')
    echo "$output" | while IFS='|' read -r pid name cpu started; do
        [[ -z "$pid" ]] && continue
        printf "${GRAY}%-8s ${WHITE}%-25s ${TEAL}%-15s ${GRAY}%-s${RESET}
" "$pid" "$name" "${cpu:-0}" "${started:-N/A}"
    done
}

top_cpu() {
    case "$os_type" in
        windows|wsl) windows_top_cpu ;;
        *)           linux_top_cpu  ;;
    esac
}

linux_top_mem() {
    printf "${WHITE}%-8s %-20s %-10s %-s${RESET}
" "PID" "COMMAND" "RSS(MB)" "TIME"
    ps -eo pid,comm,rss,etime --sort=-rss | awk 'NR>1 && NR<=6 {printf "%-8s %-20s %-10.2f %-s
", $1, $2, $3/1024, $4}' | while read -r pid comm rss time; do
        printf "${GRAY}%-8s ${WHITE}%-20s ${TEAL}%-10s ${GRAY}%-s${RESET}
" "$pid" "$comm" "$rss" "$time"
    done
}

windows_top_mem() {
    printf "${WHITE}%-8s %-25s %-15s %-s${RESET}
" "PID" "COMMAND" "WS(MB)" "STARTED"
    local output
    output=$(win_ps 'Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Id, ProcessName, @{N="WS";E={[math]::Round($_.WorkingSet/1MB,2)}}, StartTime | ForEach-Object { "$($_.Id)|$($_.ProcessName)|$($_.WS)|$($_.StartTime)" }')
    echo "$output" | while IFS='|' read -r pid name ws started; do
        [[ -z "$pid" ]] && continue
        printf "${GRAY}%-8s ${WHITE}%-25s ${TEAL}%-15s ${GRAY}%-s${RESET}
" "$pid" "$name" "$ws" "${started:-N/A}"
    done
}

top_mem() {
    case "$os_type" in
        windows|wsl) windows_top_mem ;;
        *)           linux_top_mem  ;;
    esac
}

linux_extra_stats() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo -e "${WHITE}OS:${RESET}      ${TEAL}$PRETTY_NAME${RESET}"
    else
        echo -e "${WHITE}OS:${RESET}      ${TEAL}$(uname -s) $(uname -r)${RESET}"
    fi
    echo -e "${WHITE}Uptime:${RESET}   ${TEAL}$(uptime -p 2>/dev/null | sed 's/up //' || uptime)${RESET}"
    echo -e "${WHITE}Load:${RESET}     ${TEAL}$(awk '{print $1,$2,$3}' /proc/loadavg 2>/dev/null || echo N/A)${RESET}"
    echo -e "${WHITE}Users:${RESET}    ${TEAL}$(who | wc -l) user(s)${RESET}"
    if command -v lastb >/dev/null 2>&1; then
        echo -e "${WHITE}Failed:${RESET}   ${AMBER}$(lastb 2>/dev/null | wc -l)${RESET}"
    else
        echo -e "${WHITE}Failed:${RESET}   ${GRAY}N/A${RESET}"
    fi
}

windows_extra_stats() {
    local os_name os_ver uptime users
    os_name=$(win_ps '(Get-CimInstance Win32_OperatingSystem).Caption')
    os_ver=$(win_ps '(Get-CimInstance Win32_OperatingSystem).Version')
    echo -e "${WHITE}OS:${RESET}      ${TEAL}${os_name:-Windows} (Version ${os_ver:-N/A})${RESET}"
    uptime=$(win_ps '$t = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; "$($t.Days)d $($t.Hours)h $($t.Minutes)m"')
    echo -e "${WHITE}Uptime:${RESET}   ${TEAL}${uptime:-N/A}${RESET}"
    users=$(win_ps '(Get-CimInstance Win32_LogonSession | Where-Object { $_.LogonType -eq 2 -or $_.LogonType -eq 10 }).Count')
    echo -e "${WHITE}Users:${RESET}    ${TEAL}${users:-0} user(s)${RESET}"
    local fails
    fails=$(win_ps '(Get-WinEvent -FilterHashtable @{LogName="Security";Id=4625} -MaxEvents 50 -ErrorAction SilentlyContinue | Measure-Object).Count')
    echo -e "${WHITE}Failed:${RESET}   ${AMBER}${fails:-N/A}${RESET}"
}

extra_stats() {
    case "$os_type" in
        windows|wsl) windows_extra_stats ;;
        *)           linux_extra_stats  ;;
    esac
}

linux_battery_status() {
    local batdir=""
    if [ -d "/sys/class/power_supply/BAT0" ]; then batdir="/sys/class/power_supply/BAT0"
    elif [ -d "/sys/class/power_supply/BAT1" ]; then batdir="/sys/class/power_supply/BAT1"; fi

    if [ -z "$batdir" ]; then echo "No battery detected"; return; fi

    local capacity status
    capacity=$(cat "$batdir/capacity" 2>/dev/null || echo "N/A")
    status=$(cat "$batdir/status" 2>/dev/null || echo "N/A")
    
    if [[ "$capacity" =~ ^[0-9]+$ ]]; then
        local gauge=$(get_gauge_string "$capacity")
        local color_name=$(get_gauge_color "$capacity")
        local color_var="${!color_name}"
        printf "${WHITE}Level:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%s%%${RESET}
" "$capacity"
    else
        echo "Battery Level: $capacity"
    fi
    echo -e "${WHITE}Status:${RESET}  ${TEAL}$status${RESET}"
}

windows_battery_status() {
    local bat_info
    bat_info=$(win_ps '$bat = Get-CimInstance Win32_Battery; if ($bat) { "$($bat.EstimatedChargeRemaining) $($bat.BatteryStatus)" } else { "NOBAT" }')
    if [[ "$bat_info" == "NOBAT" || -z "$bat_info" ]]; then echo "No battery detected"; return; fi
    local level bstatus
    read -r level bstatus <<<"$bat_info"
    
    local gauge=$(get_gauge_string "$level")
    local color_name=$(get_gauge_color "$level")
    local color_var="${!color_name}"
    printf "${WHITE}Level:${RESET}  ${color_var}${gauge}${RESET} ${color_var}%s%%${RESET}
" "$level"
    
    case "$bstatus" in
        1) echo -e "${WHITE}Status:${RESET}  ${TEAL}Discharging${RESET}" ;;
        2) echo -e "${WHITE}Status:${RESET}  ${TEAL}Charging${RESET}" ;;
        3) echo -e "${WHITE}Status:${RESET}  ${TEAL}Fully Charged${RESET}" ;;
        4) echo -e "${WHITE}Status:${RESET}  ${AMBER}Low${RESET}" ;;
        5) echo -e "${WHITE}Status:${RESET}  ${CRIMSON}Critical${RESET}" ;;
        *) echo -e "${WHITE}Status:${RESET}  ${GRAY}Unknown${RESET}" ;;
    esac
}

battery_status() {
    case "$os_type" in
        windows|wsl) windows_battery_status ;;
        *)           linux_battery_status  ;;
    esac
}

show_hidden_background() {
    case "$os_type" in
        windows|wsl) echo "Hidden processes require a POSIX environment." ;;
        *)
            printf "${WHITE}%-8s %-5s %-20s %-s${RESET}
" "PID" "TTY" "COMMAND" "STAT"
            ps -eo pid,tty,comm,stat | awk '$2 == "?" {printf "%-8s %-5s %-20s %-s
", $1, $2, $3, $4}' | while read -r pid tty comm stat; do
                printf "${GRAY}%-8s ${WHITE}%-5s ${WHITE}%-20s ${GRAY}%-s${RESET}
" "$pid" "$tty" "$comm" "$stat"
            done
            ;;
    esac
}

linux_kill_process() {
    local pid="$1"
    if ! kill -0 "$pid" 2>/dev/null; then echo "Error: PID $pid not found."; return 1; fi
    local info=$(ps -p "$pid" -o pid,comm,args --no-headers 2>/dev/null)
    echo "PID: $pid | Info: $info"
    read -rp "Kill this process? [y/N] " answer
    if [[ "$answer" =~ ^[yY] ]]; then
        kill "$pid" && echo "Terminated." || echo "Failed."
    else
        echo "Aborted."
    fi
}

windows_kill_process() {
    local pid="$1"
    local proc_name=$(win_ps "try { (Get-Process -Id $pid -ErrorAction Stop).ProcessName } catch { 'NOTFOUND' }")
    if [[ "$proc_name" == "NOTFOUND" ]]; then echo "Error: PID $pid not found."; return 1; fi
    echo "PID: $pid | Name: $proc_name"
    read -rp "Kill this process? [y/N] " answer
    if [[ "$answer" =~ ^[yY] ]]; then
        win_ps "Stop-Process -Id $pid -Force" && echo "Terminated." || echo "Failed."
    else
        echo "Aborted."
    fi
}

kill_process() {
    local pid="$1"
    [[ -z "$pid" ]] && return 1
    case "$os_type" in
        windows|wsl) windows_kill_process "$pid" ;;
        *)           linux_kill_process "$pid"  ;;
    esac
}

wifi_list() {
    if ! command -v nmcli >/dev/null 2>&1 && ! command -v iw >/dev/null 2>&1; then
        echo "Error: nmcli or iw not found."
        return 1
    fi

    if command -v nmcli >/dev/null 2>&1; then
        nmcli -t -f SSID,BARS,SECURITY device wifi list | awk -F: '{
            ssid = $1; 
            bars = $2; 
            sec = $3; 
            if (ssid == "") ssid = "[Hidden]"; 
            printf "%-30s %-5s %-10s\n", ssid, bars, sec
        }' | head -n 15 | while read -r ssid bars sec; do
            printf "${WHITE}%-30s ${TEAL}%-5s ${GRAY}%-10s${RESET}\n" "$ssid" "$bars" "$sec"
        done
    elif command -v iw >/dev/null 2>&1; then
        local iface=$(iw dev | awk '$1=="Interface"{print $2; exit}')
        if [ -z "$iface" ]; then echo "No wireless interface detected."; return 1; fi
        iw dev "$iface" scan 2>/dev/null | awk '/SSID:/{gsub(/.*SSID:[ 	]*/,"",$0); gsub(/"/,"",$0); print $0}' | sort -u | head -n 15 | while read -r ssid; do
            printf "${WHITE}%-30s ${GRAY}[IW-SCAN]${RESET}
" "$ssid"
        done
    else
        echo "No compatible Wi-Fi tools found."
        return 1
    fi
}

wifi_current() {
    if ! command -v nmcli >/dev/null 2>&1; then echo "Error: nmcli not found."; return 1; fi
    local res=$(nmcli -t -f ACTIVE,SSID device wifi | grep '^yes' | cut -d: -f2)
    if [[ -z "$res" ]]; then echo "Not connected."; else echo -e "${WHITE}SSID:${RESET}  ${TEAL}$res${RESET}"; fi
}

wifi_connect() {
    local ssid="$1"
    local password="${2:-}"
    if ! command -v nmcli >/dev/null 2>&1; then echo "Error: nmcli not found."; return 1; fi
    if [[ -n "$password" ]]; then
        nmcli device wifi connect "$ssid" password "$password"
    else
        nmcli device wifi connect "$ssid" --ask
    fi
}

# =====================================================================
# Argument Parsing
# =====================================================================
show_hidden=false
kill_pid=""
wifi_list_req=false
wifi_current_req=false
wifi_connect_ssid=""
wifi_connect_password=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all) show_hidden=true; shift ;;
        --kill) kill_pid="${2:-}"; shift 2 ;;
        --wifi-list) wifi_list_req=true; shift ;;
        --wifi-current) wifi_current_req=true; shift ;;
        --wifi-connect) wifi_connect_ssid="${2:-}"; shift 2; [[ -n "${1:-}" && "${1:-}" != -* ]] && wifi_connect_password="$1" && shift ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  -a, --all                Show hidden background processes"
            echo "  --kill <PID>             Kill specified PID"
            echo "  --wifi-list              List Wi-Fi networks"
            echo "  --wifi-current           Show current Wi-Fi"
            echo "  --wifi-connect <SSID> [pw] Connect to Wi-Fi"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# =====================================================================
# Main Execution
# =====================================================================
prompt_os_selection

if [[ "$wifi_list_req" == true ]]; then wifi_list; exit $?; fi
if [[ "$wifi_current_req" == true ]]; then wifi_current; exit $?; fi
if [[ -n "$wifi_connect_ssid" ]]; then wifi_connect "$wifi_connect_ssid" "$wifi_connect_password"; exit $?; fi
if [[ -n "$kill_pid" ]]; then kill_process "$kill_pid"; exit $?; fi

while true; do
    clear
    draw_banner
    draw_snapshot
    draw_main_menu
    
    read -rp "  Selection: " choice
    echo ""
    
    case "$choice" in
        1) render_panel "CPU Usage" "$(cpu_usage)" "⚙️" ;;
        2) render_panel "Memory Usage" "$(mem_usage)" "🧠" ;;
        3) render_panel "Disk Usage" "$(disk_usage)" "💾" ;;
        4) render_panel "Top 5 CPU Processes" "$(top_cpu)" "⚡" ;;
        5) render_panel "Top 5 Memory Processes" "$(top_mem)" "📊" ;;
        6) render_panel "System Information" "$(extra_stats)" "ℹ️" ;;
        7) render_panel "Battery Status" "$(battery_status)" "🔋" ;;
        8) render_panel "Hidden Processes" "$(show_hidden_background)" "👻" ;;
        9) render_panel "Wi-Fi List" "$(wifi_list)" "📶" ;;
        10) render_panel "Wi-Fi Current" "$(wifi_current)" "🌐" ;;
        11) 
            render_panel "CPU Usage" "$(cpu_usage)" "⚙️"
            render_panel "Memory Usage" "$(mem_usage)" "🧠"
            render_panel "Disk Usage" "$(disk_usage)" "💾"
            render_panel "Top CPU" "$(top_cpu)" "⚡"
            render_panel "Top Mem" "$(top_mem)" "📊"
            render_panel "System Info" "$(extra_stats)" "ℹ️"
            render_panel "Battery" "$(battery_status)" "🔋"
            [[ "$show_hidden" == true ]] && render_panel "Hidden" "$(show_hidden_background)" "👻"
            ;;
        0) echo "Exiting..."; exit 0 ;;
        r) continue ;;
        *) ;;
    esac
    read -rn 1 -p "  Press any key to return to menu..." 
done
