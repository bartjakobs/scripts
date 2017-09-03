#!/bin/bash
# Convert media to mp3
ffmpeg -i "$1" "$1.mp3"
