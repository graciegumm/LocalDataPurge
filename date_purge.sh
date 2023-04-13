#!/bin/bash

local_path = /var/panda/CyverseData/JmscslgroupData/PandaData/
# local_path=localfiles
VIN=$(cat /etc/libpanda.d/vin)
remote_dir=`ils -r /iplant/home/sprinkjm/private-circles/$VIN/libpanda/`
# files=`ls -R /var/panda/CyverseData/JmscslgroupData/PandaData/`

# remote_path=remotefiles
FILE=$local_path/log.csv




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
  name=$(basename $file)
  if grep -q "^$(basename $file)," $FILE; then
    previous_status=$(grep "$(basename "$file")" "$FILE" | awk -F', ' '{print $6}')
    # Check if it has been uploaded already. Update the upload status.
    if [ "$previous_status" = "Not Uploaded" ]; then
      if [ -f "$remote_path/$(basename "$file")" ]; then
        status="Uploaded"
      else
        status="Not Uploaded"
        # This will delete the file from the log if it has not been uploaded.
        sed -i "/^$(basename $file),/d" $FILE
      fi
    fi
  else
    echo "Processing file $name ..."
    year_file=${name:0:4}
    month_string=${name:5:2}
    day_string=${name:8:2}
    time_string=${name:11:8}
    date_directory=$year_file"_"$month_string"_"$day_string
    type=${name:38:3}

    if [ -f "$remote_path/$(basename "$file")" ]; then
      status="Uploaded"
    else
      status="Not Uploaded"
    fi
    echo "$(basename "$file"), $date_directory, $time_string, $type, $(stat -c %s $file), $status" >> "$FILE"
  fi
done
file_name=$(awk -F ',' 'NR==2{print $1}' $FILE)
upload_status=$(awk -F ',' 'NR==2{print $6}' $FILE)

# Start delete section

critical_memory_usage=80
memory_usage=$(free | awk 'NR==2{printf "%.2f\n", $3/($3+$4)*100}') # will replace this w the LibPanda command
#while [[ $memory_usage > $critical_memory_usage ]]
for i in 1 2 3 4; do # DELETE, just for local testing
  echo "Memory usage critical...deleting files..."
  file_name=$(awk -F ',' 'NR==2{print $1}' $FILE)
  upload_status=$(awk -F ',' 'NR==2{print $6}' $FILE)
  # Make sure the log.csv file is not empty
  if [ "$(wc -l < "$FILE")" -lt 2 ]; then
    echo "Error in deleting files: no files are available to be deleted"
    break
  fi
  # delete file if status is "Uploaded"
  if [ "$upload_status" = " Uploaded" ]; then
    echo "Deleting first file..."
    rm "${local_path}/${file_name}"
    sed -i '2d' $FILE
  fi
done
