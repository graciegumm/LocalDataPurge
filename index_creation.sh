#! /bin/bash
files=`ls -R localfiles/`
file_path=localfiles
FILE=localfiles/log.csv
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo "host, data, checkout" >> $file_path/log.csv
fi
