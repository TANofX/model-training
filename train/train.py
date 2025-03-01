#!/usr/bin/env python3
from ultralytics import YOLO
import kdl
from pathlib import Path
import shutil
import os
import json
import torch

if torch.cuda.is_available():
    print("ROCM is available.")
else:
    print("ROCM is NOT available")
    exit(1)

# CWD relative to this file is ../work/tmp/train/

# read config file
with open('../../../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)
name = config['name'].args[0]
model = config['model'].args[0]
imgsz = int(config['imgsz'].args[0])
train_config = config['train']
epochs = int(train_config['epochs'].args[0])

# Yolo is really bad about guessing where the datasets directory is,
# so we need to tell it by setting it in $YOLO_CONFIG_DIR/settings.json
yolo_config_dir = os.environ['YOLO_CONFIG_DIR']
datasets_dir = Path(os.getcwd(), '../../datasets').resolve()
with open(Path(yolo_config_dir) / 'settings.json', 'w', encoding='utf-8') as f:
    f.write(json.dumps({'datasets_dir': datasets_dir.as_posix()}))

# Yolo makes up insane paths if you do not give it an absolute path for data.yaml.
data_yaml_path = datasets_dir / name / 'data.yaml'

# Run training
model = YOLO(model)
model.train(data=data_yaml_path, project='.', epochs=epochs, imgsz=imgsz)

# Move the output file
shutil.move('train/weights/best.pt', f"../../{name}.pt")

print('Training complete')
