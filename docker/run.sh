#!/bin/bash

# This is for running in Docker.
# TODO: modify to also run locally.

set -ex

# Verify that ROCM is supported
pushd verify-rocm
uv run verify-rocm.py
popd

# Download the dataset from Roboflow to ./work/dataset/
pushd download-dataset
uv run download-dataset.py
popd

# Train the model, output ./work/best.pt
pushd train
uv run ./train.sh
popd

# Export to ONNX, output ./work/best.onnx
pushd export-onnx
source venv/bin/activate
./export.sh
deactivate
popd

# Convert ONNX to RKNN, output ./work/best-640-640-yolov8n.rknn
pushd onnx-to-rknn
./gen-quant-images-txt.sh
uv run convert.py
popd

# Copy output files for PhotonVision to /output/
cp best-640-640-yolov8n-labels.txt /output/
cp work/best-640-640-yolov8n.rknn /output/
