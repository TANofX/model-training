#!/bin/sh

# This has `format=rknn` even though it is creating ONNX. See the ulralytics fork diff for details.
yolo mode=export format=rknn model=../work/best.pt
