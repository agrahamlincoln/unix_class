#!/usr/bin/bash

# check for required arguments
if [ -z "$1" ]; then
  echo "Usage: cap-check <email@domain.com>"
  exit 1
fi
EMAIL_DESTINATION=$1

#First find which command will give us output
if DF_OUTPUT=$(/usr/local/bin/df -t nfs -t ufs -t ext4 -t ext2); then
  #/usr/local/bin/df works!
  # This works on ce.uml.edu
  echo "/usr/local/bin/df works!"
elif DF_OUTPUT=$(df -t nfs -t ufs -t ext4 -t ext2); then
  #df works!
  # This works on cyberserver.uml.edu
  echo "df works!"
else
  echo "Error! No 'df' command found."
fi

notify_count=0
echo "$DF_OUTPUT" | awk '
	!/proc/ && !/^Filesystem/ { print $6 " " $5 }
' | while read output;
do
  partition=($output)
  percentFull=`sed 's/.$//' <<< "${partition[1]}"`

  if [ "$percentFull" -ge "90" ]; then
    subject="Critical Warning: File system $partition is at $percentFull% of capacity"
    mailx -s "$subject" $EMAIL_DESTINATION <<< "$subject"
    echo $subject
  elif [ "$percentFull" -ge "60" ]; then
    subject="Warning: File system $partition is at $percentFull% of capacity"
    mailx -s "$subject" $EMAIL_DESTINATION  <<< "$subject"
    echo $subject " Notification sent to $EMAIL_DESTINATION"
  fi
done