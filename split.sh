#!/usr/bin/env bash
set -euo pipefail

# Check for input argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <input-file>.m4a"
  exit 1
fi

input="$1"

# Verify input exists
if [ ! -f "$input" ]; then
  echo "❌ File '$input' not found."
  exit 1
fi

# Strip .m4a extension to get base name
basename="$(basename "$input" .m4a)"
output_dir="$basename/chunks"

# If output folder exists, warn and delete it
if [ -d "$output_dir" ]; then
  echo "Directory '$output_dir' already exists; proceeding to delete it."
  rm -rf "$output_dir"
fi

# Create target directory
mkdir -p "$output_dir"

# Split into 5-minute (.ts) chunks and generate HLS playlist
ffmpeg -i "$input" \
  -f segment \
  -segment_time 300 \
  -c:a aac \
  -b:a 128k \
  -vn \
  -segment_list "${output_dir}/${basename}_playlist.m3u8" \
  -segment_list_type m3u8 \
  "${output_dir}/${basename}_chunk_%03d.ts"

echo "✅ Finished splitting '$input' into '$output_dir' and creating playlist."
