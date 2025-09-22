#!/bin/bash
INPUT="$1"
OUTPUT="$2"
ffmpeg -y -i "$INPUT" -ar 8000 -ac 1 -c:a pcm_s16le "$OUTPUT"
DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT")
echo "$DUR"