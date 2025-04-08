#!/bin/bash

# chmod +x run_user_cmds.sh
# sudo ./run_user_cmds.sh

# Define input files
USER_FILE="usernames.txt"
CMD_FILE="commands.txt"

# Check if input files exist
if [[ ! -f "$USER_FILE" || ! -f "$CMD_FILE" ]]; then
  echo "Missing usernames.txt or commands.txt"
  exit 1
fi

# Loop through each user
while IFS= read -r user; do
  echo "==== Running commands as user: $user ===="

  # Loop through each command
  while IFS= read -r cmd; do
    echo "--- Running: $cmd"
    
    # Execute the command as the specified user
    sudo -u "$user" bash -c "$cmd"

    echo ""
  done < "$CMD_FILE"
done < "$USER_FILE"
