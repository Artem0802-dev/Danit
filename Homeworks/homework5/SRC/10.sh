#!/bin/bash

# Directory to watch
WATCH_DIR="$HOME/watch"

# Check if the directory exists, create it if it doesn't
mkdir -p "$WATCH_DIR"

# Monitor the directory for new files
inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read FILE
do
    # Check if the file is a regular file
    if [ -f "$WATCH_DIR/$FILE" ]; then
        # Print the content of the file
        echo "New file detected: $FILE"
        echo "Content of $FILE:"
        cat "$WATCH_DIR/$FILE"
        
        # Rename the file to *.back
        mv "$WATCH_DIR/$FILE" "$WATCH_DIR/$FILE.back"
        echo "File renamed to $FILE.back"
    fi