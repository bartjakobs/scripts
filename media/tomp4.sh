#!/bin/bash
# Convert media to mp4
ffmpeg -i "$1" -vcodec h264 -profile:v main -level 4.0 "$1.mp4"
