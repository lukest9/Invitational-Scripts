#!/bin/bash

# File to run when PIDs aren't changing, runs every 10s
# Log file to track processes
LOG_FILE="/tmp/last_pid_log.txt"

# Define authorized users (change this list to your authorized users)
AUTHORIZED_USERS=("root" "admin")  # Add authorized users here

# Initialize the log file if it doesn't exist
if [[ ! -e "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
fi

# Function to check for new login processes by PID
check_new_pid_logins() {
    # Get a list of current SSH login processes
    current_processes=$(ps -eo pid,uid,user,cmd --sort=start_time | grep 'sshd: ')

    # Compare the list of current processes with the stored process list
    new_processes=$(comm -13 "$LOG_FILE" <(echo "$current_processes"))

    # If new processes (i.e., new logins) are detected
    if [[ -n "$new_processes" ]]; then
        echo "New login processes detected:"

        # Iterate through each new process
        while read -r process; do
            pid=$(echo "$process" | awk '{print $1}')
            user=$(echo "$process" | awk '{print $3}')
            
            # Check if the user is in the authorized list
            if [[ ! " ${AUTHORIZED_USERS[@]} " =~ " ${user} " ]]; then
                # If the user is not authorized, kill the process
                echo "Killing session for unauthorized user: $user (PID: $pid)"
                kill -9 "$pid"
                echo "Session for user $user has been terminated (PID: $pid)."
            fi
        done <<< "$new_processes"
    fi
}

# Loop to continuously check for new login processes by PID
while true; do
    # Check for new login processes
    check_new_pid_logins

    # Update the log file with the current list of processes
    ps -eo pid,uid,user,cmd --sort=start_time | grep 'sshd: ' > "$LOG_FILE"

    # Sleep for a defined period before checking again (e.g., every 10 seconds)
    sleep 10
done
