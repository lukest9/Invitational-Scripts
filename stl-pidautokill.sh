#!/bin/bash

# Check if an argument (threshold PID) was passed
if [ -z "$1" ]; then
    echo "Usage: $0 <PID threshold>"
    exit 1
fi

# Set the threshold PID value from the argument
THRESHOLD_PID=$1

# Function to check and kill processes with PID > threshold
kill_processes_above_threshold() {
    # List all running processes with their PID
    ps -eo pid,cmd --sort=pid | while read pid cmd; do
        # Skip the header line
        if [[ "$pid" == "PID" ]]; then
            continue
        fi

        # Check if PID is greater than the threshold
        if [ "$pid" -gt "$THRESHOLD_PID" ]; then
            echo "Killing process with PID: $pid (Command: $cmd)"
            kill -9 "$pid"
            echo "Process with PID: $pid has been terminated."
        fi
    done
}

# Loop to monitor and kill processes periodically (every 10 seconds)
while true; do
    kill_processes_above_threshold
    # Sleep for a short period before checking again (adjust as needed)
    sleep 1
done
