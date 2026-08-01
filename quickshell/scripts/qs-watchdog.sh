#!/usr/bin/env bash
# Quickshell watchdog - auto-restarts on crash (Qt6+NVIDIA scene graph bug)
# This handles the known derefWindow segfault during monitor hot-plug events.

QS_PID=""

cleanup() {
    echo "[qs-watchdog] Terminated. Killing Quickshell..."
    if [[ -n "$QS_PID" ]]; then
        kill "$QS_PID" 2>/dev/null
        wait "$QS_PID" 2>/dev/null
    fi
    pkill -x quickshell 2>/dev/null
    pkill -x .quickshell-wra 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT SIGHUP

RESTART_DELAY=1
MAX_RAPID_RESTARTS=5
RAPID_WINDOW=10 # seconds

declare -a restart_times=()

while true; do
    # Clean up stale processes
    pkill -x quickshell 2>/dev/null
    pkill -x .quickshell-wra 2>/dev/null
    sleep 0.3

    echo "[qs-watchdog] Starting Quickshell..."
    export TZ=":/etc/localtime"
    quickshell &
    QS_PID=$!

    # Wait for it to exit
    wait $QS_PID
    EXIT_CODE=$?
    QS_PID=""

    # Only restart on real crash signals:
    # 139 = SIGSEGV, 134 = SIGABRT, 133 = SIGTRAP, 135 = SIGBUS
    if [[ "$EXIT_CODE" != "139" && "$EXIT_CODE" != "134" && "$EXIT_CODE" != "133" && "$EXIT_CODE" != "135" ]]; then
        echo "[qs-watchdog] Quickshell exited with code $EXIT_CODE (not a crash). Stopping watchdog."
        break
    fi

    NOW=$(date +%s)

    # Track rapid restarts to avoid infinite crash loops
    restart_times+=("$NOW")
    new_times=()
    for t in "${restart_times[@]}"; do
        if (( NOW - t < RAPID_WINDOW )); then
            new_times+=("$t")
        fi
    done
    restart_times=("${new_times[@]}")

    if (( ${#restart_times[@]} >= MAX_RAPID_RESTARTS )); then
        echo "[qs-watchdog] Too many rapid crashes (${#restart_times[@]} in ${RAPID_WINDOW}s). Stopping."
        break
    fi

    echo "[qs-watchdog] Quickshell crashed (exit code $EXIT_CODE). Restarting in ${RESTART_DELAY}s..."
    sleep $RESTART_DELAY
done
