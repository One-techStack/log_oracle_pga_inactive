#!/bin/bash

# This file is supposed to act as a complementary script to the monitor_oracle.sh script.
# If using the monitor_oracle.sh script, you can use this script to rotate the log file and send it via email, if you run that in a cron job.
# With the default values below, it assumes the files are all stored in the current working directory. Adapt as needed.
# By default, the log will rotate when it reaches 100MByte. It will then be zipped and send via email to the specified email address(es).
# If you don't want to send emails, comment out the send_email function.
# If an old zip file existst, it will be overwritten by the new one.

# Configuration
LOG_FILE="monitor_oracle.log"       # Path to your log file
ZIP_FILE="monitor_oracle.log.zip"   # Path to your zip file
SIZE_THRESHOLD=100                  # Size threshold in MB

# SInitialize email list
EMAIL_LIST=() # Set EMAIL_LIST=("email1@example.com" "email2@example.com") - Add or remove emails as needed. If EMAIL_LIST
              # is empty, the script will exit. If you don't want to send emails, comment out the send_email function.

# Function to send email
function send_email {
  for EMAIL in "${EMAIL_LIST[@]}"; do
    echo "Sending email to $EMAIL"
    echo "Please find the attached log file." | mail -a "$ZIP_FILE" -s "Log file" -- $EMAIL
  done
}

# Main

# Check if mail is available, if not, exit
if ! command -v mail &> /dev/null; then
  echo "mail could not be found. Please install mail."
  exit
fi

# Check if Email(s) are not default, if not, exit
if [[ ${#EMAIL_LIST[@]} -eq 0 ]]; then
  echo "Please set the email address(es) to send the log file to."
  exit
fi


FILE_SIZE=$(du -m "$LOG_FILE" | cut -f1) # Get file size in MB

if (( FILE_SIZE >= SIZE_THRESHOLD )); then
  echo "Log file size has reached the threshold." 
  zip -r $ZIP_FILE $LOG_FILE

  # Check if zip was successful
  if [[ $? -eq 0 ]]; then
    send_email
    rm $LOG_FILE
  else
    echo "An error occurred during zipping the log file."
  fi
done