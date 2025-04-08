#!/bin/bash

# File list to monitor for changes
FILE_LIST=("file1.txt" "file2.txt" "file3.txt")  # Add your files here
# To monitor a specific directory (e.g., /etc/), replace the above list with the directory

# Function to monitor file changes
monitor_files() {
  for file in "${FILE_LIST[@]}"; do
    if [[ ! -e "$file" ]]; then
      echo "Error: File $file does not exist!"
      continue
    fi

    # Monitor the file using inotifywait (runs in the background)
    inotifywait -m -e modify,create,delete "$file" | while read -r line; do
      echo "Error: Change detected in $file: $line"
    done &
  done
}

# Function to monitor the number of logged-in users
monitor_logged_in_users() {
  prev_user_count=$(who | wc -l)  # Get initial count of logged-in users

  while true; do
    current_user_count=$(who | wc -l)  # Get the current count of logged-in users

    if [[ "$current_user_count" -ne "$prev_user_count" ]]; then
      echo "Error: Number of logged-in users changed. Previous: $prev_user_count, Current: $current_user_count"
      prev_user_count="$current_user_count"
    fi

    sleep 5  # Check every 5 seconds (adjust as needed)
  done &
}

# Start monitoring functions
monitor_files
monitor_logged_in_users

# Keep the script running indefinitely
while true; do
  sleep 60  # Sleep to keep the script running in the background
done
