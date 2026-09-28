#!/bin/bash
# animate.sh: turn a folder of PNG frames into an MP4 and a GIF.
# Runs generate_video_ffmpeg.py, then mp4_to_gif_converter.py on the new MP4,
# both with their default settings.
#
# Usage: ./animate.sh <input_folder> <output_folder>
#
# The two Python scripts must sit in the same folder as this script.

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_folder> <output_folder>"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$OUTPUT_DIR"

# Step 1: Generate MP4 (exits here if FFmpeg fails)
python3 "$SCRIPT_DIR/generate_video_ffmpeg.py" "$INPUT_DIR" "$OUTPUT_DIR"

# Step 2: Find the most recent MP4 file in output directory
MP4_FILE=$(ls -t "$OUTPUT_DIR"/*.mp4 2>/dev/null | head -n 1 || true)

if [ -z "$MP4_FILE" ]; then
    echo "Error: No MP4 generated in $OUTPUT_DIR"
    exit 1
fi

# Step 3: Convert MP4 to GIF (written next to the MP4)
python3 "$SCRIPT_DIR/mp4_to_gif_converter.py" "$MP4_FILE"
