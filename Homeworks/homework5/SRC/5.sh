#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_file> <destination_file>"
    exit 1
fi
source=$1
destination=$2
cp "$source" "$destination"
if [ $? -eq 0 ]; then
    echo "File copied successfully."
else
    echo "File copy failed."
fi