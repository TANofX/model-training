#!/usr/bin/env python3
from ultralytics import YOLO
import kdl

# read config file
with open('../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)['train']
model = config['model'].args[0]
epochs = int(config['epochs'].args[0])
imgsz = int(config['imgsz'].args[0])

model = YOLO(model)

model.train(data='../work/dataset/data.yaml', project='../work/tmp', epochs=epochs, imgsz=imgsz)
