#!/bin/sh
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Ultralytics, by default, writes settings to ~/.config/Ultralytics,
# which is terrible because there are model-specific file paths in there.
# So we will use ./yolo-config for our config files
export YOLO_CONFIG_DIR=yolo-config

mkdir -p ../work/tmp
rm -rf ../work/tmp/train

set -ex
yolo detect train \
	data=../work/dataset/data.yaml \
	model=yolov8n.yaml \
	project=../work/tmp \
	epochs=2 \
	imgsz=640

# Move the output file
mv ../work/tmp/train/weights/best.pt ../work/

# Remove files that yolo leaves around
rm -rf yolo-config/Arial.ttf yolo11n.pt ../work/tmp/train

echo "Training complete"
