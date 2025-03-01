#!/usr/bin/env python3

from ultralytics import YOLO
import kdl

# read config file
with open('../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)
name = config['name'].args[0]

model = YOLO(f"../work/{name}.pt")

# This has `format=rknn` even though it is creating ONNX. See the ulralytics fork diff for details.
model.export(format="onnx")
