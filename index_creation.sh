#!/bin/bash

local_path=localfiles
remote_path=remotefiles
FILE=$local_path/log.csv

# Below is only commented out because I am running this on my laptop
# VIN=$(cat /etc/libpanda.d/vin)
# remote_dir=`ils -r /iplant/home/sprinkjm/private-circles/$VIN/libpanda/`
# files=`ls -R /var/panda/CyverseData/JmscslgroupData/PandaData/`
# local_path = /var/panda/CyverseData/JmscslgroupData/PandaData/

# Create the index (log.csv) file if it doesn't already exist
if [ -f "$FILE" ]; then
  echo "$(basename $FILE) exists..."
else
  echo "Name, Date, Time, Type, Size (Bytes), Status" >> "$FILE"
  echo "Creating index file (log.csv)..."
fi

# Loop over each file on the RPI. Directory needs to be tweaked when running on an actual RPI.
for file in "$local_path"/*; do
  # Ignore the log.csv file
  if [[ "$(basename "$file")" == "log.csv" ]]; then
    continue
  fi
  # Check if file has already been added to log.csv
  if grep -q "^$(basename $file)," $FILE; then
    previous_status=$(grep "$(basename "$file")" "$FILE" | awk -F', ' '{print $6}')
    # Check if it has been uploaded already. Update the upload status.
    if [ "$previous_status" = "Not Uploaded" ]; then
      if [ -f "$remote_path/$(basename "$file")" ]; then
        status="Uploaded"
      else
        status="Not Uploaded"
        # This will delete the file from the log if it has not been uploaded.
        sed -i "/^$(basename $file),/d" $FILE #testing if this will remove a file
      fi
    fi
  else
    echo "Processing file ${file:11:54} ..."
    #year_file=${file:0:4}
    year_file=${file:11:4} #DELETE
    #month_string=${file:5:2}
    month_string=${file:16:2} #DELETE
    #day_string=${file:8:2}
    day_string=${file:19:2} #DELETE
    #time_string=${file:11:8}
    time_string=${file:22:8} #DELETE
    date_directory=$year_file"_"$month_string"_"$day_string
    #type=${file:38:3}
    type=${file:49:3} #DELETE

    if [ -f "$remote_path/$(basename "$file")" ]; then
      status="Uploaded"
    else
      status="Not Uploaded"
    fi
    echo "$(basename "$file"), $date_directory, $time_string, $type, $(stat -c %s $file), $status" >> "$FILE"

  fi
done
