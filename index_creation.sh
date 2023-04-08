#!/bin/bash

file_path=localfiles
FILE=$file_path/log.csv

# Create the index (log.csv) file if it doesn't already exist
if [ -f "$FILE" ]; then
  echo "$FILE exists..."
else
  echo "host, data, checkout" >> "$FILE"
  echo "Creating index file (log.csv)..."
fi

# Loop over each file on the RPI
for file in "$file_path"/*; do
  if [[ "$(basename "$file")" == "log.csv" ]]; then
    echo "Skipping file $file ..."
    continue
  fi
  # Perform an action on the file
  echo "Processing file $file ..."
done
