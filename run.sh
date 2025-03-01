#!/bin/bash

set -ex

# Download the dataset from Roboflow to ./work/dataset/
pushd download-dataset
uv sync
uv run download-dataset.py
popd

# Train the model, output ./work/{name}.pt
pushd train
uv sync
uv run ./train.sh
popd

# Export to ONNX, output ./work/{name}.onnx
pushd export-onnx
uv sync
uv run export.py
popd

# Convert ONNX to RKNN, output ./work/{name}-{imgsz}-{imgsz}-{model}.rknn
pushd onnx-to-rknn
uv sync
uv run convert.py
popd

echo Success!
