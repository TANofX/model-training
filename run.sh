#!/bin/bash
set -ex
pushd verify-rocm
uv run verify-rocm.py
popd

pushd download-dataset
uv run download-dataset.py
popd

pushd train
uv run ./train.sh
cp output/train/weights/best.pt ..
popd

pushd export-onnx
source venv/bin/activate
yolo mode=export format=rknn model=../best.pt
deactivate
popd

pushd onnx-to-rknn
./gen-quant-images-txt.sh
uv run convert.py
