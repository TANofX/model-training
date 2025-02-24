#!/bin/sh
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Ultralytics, by default, writes settings to ~/.config/Ultralytics,
# which is terrible because there are model-specific file paths in there.
# So we will use ./yolo-config for our config files
export YOLO_CONFIG_DIR=yolo-config

rm -rf output

set -ex
yolo detect train \
	data=../dataset/data.yaml \
	model=yolov8n.yaml \
	project=output \
	epochs=10 \
	imgsz=640
