#!/bin/bash
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \" $UPDATES\", \"tooltip\": \"$UPDATES updates available\"}"
else
    echo "{\"text\": \"\"}"
fi
