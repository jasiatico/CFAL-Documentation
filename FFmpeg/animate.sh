#!/bin/bash

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./animate <input_folder> <output_folder>"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Step 1: Generate MP4
python3 ~/scripts/generate_video_ffmpeg.py "$INPUT_DIR" "$OUTPUT_DIR"

# Step 2: Find the most recent MP4 file in output directory
MP4_FILE=$(ls -t "$OUTPUT_DIR"/*.mp4 | head -n 1)

if [ -z "$MP4_FILE" ]; then
    echo "Error: No MP4 generated in $OUTPUT_DIR"
    exit 1
fi

# Step 3: Convert MP4 to GIF
python3 ~/scripts/mp4_to_gif_converter.py "$MP4_FILE"
