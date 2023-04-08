#! /bin/bash
files=`ls -R localfiles/` #will need to be updated to pi folder
file_path=localfiles #will need to be updated to pi folder
FILE=$file_path/log.csv
if [ -f "$FILE" ]; then
    echo "$FILE exists..."
else
    echo "host, data, checkout" >> $file_path/log.csv
    echo "Creating index file (log.csv)..."
fi
