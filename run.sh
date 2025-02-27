#!/bin/bash

set -ex

# Download the dataset from Roboflow to ./work/dataset/
pushd download-dataset
uv sync
uv run download-dataset.py
popd

# Train the model, output ./work/best.pt
pushd train
uv sync
uv run ./train.sh
popd

# Export to ONNX, output ./work/best.onnx
pushd export-onnx
uv sync
uv run ./export.sh
popd

# Convert ONNX to RKNN, output ./work/best-640-640-yolov8n.rknn
pushd onnx-to-rknn
./gen-quant-images-txt.sh
uv sync
uv run convert.py
popd

echo Success!
