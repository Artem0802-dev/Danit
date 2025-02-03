#!/bin/bash
echo "Enter a filename:"
read filename
if [ -f "$filename" ]; then
    echo "File contents:"
    cat "$filename"
else
    echo "Error: $filename does not exist or is not a file."
fi