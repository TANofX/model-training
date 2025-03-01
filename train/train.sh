#!/bin/sh
export HSA_OVERRIDE_GFX_VERSION=10.3.0

set -ex

# Verify ROCM is working
python3 ./verify-rocm.py

# Ultralytics, by default, writes settings to ~/.config/Ultralytics,
# which is terrible because there are model-specific file paths in there.
# So we will use ./yolo-config for our config files
export YOLO_CONFIG_DIR=yolo-config

mkdir -p ../work/tmp
rm -rf ../work/tmp/train

# Run the training
python3 ./train.py

# Move the output file
mv ../work/tmp/train/weights/best.pt ../work/

# Remove files that yolo leaves around
rm -rf yolo-config/Arial.ttf yolo11n.pt ../work/tmp/train

echo "Training complete"
