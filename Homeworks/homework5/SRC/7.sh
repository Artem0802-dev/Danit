#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi
filename=$1
if [ -f "$filename" ]; then
    lines=$(wc -l < "$filename")
    echo "Number of lines in $filename: $lines"
else
    echo "$filename does not exist."
fi