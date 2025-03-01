#!/usr/bin/env python
# Adapted from https://github.com/airockchip/rknn_model_zoo/blob/cc541636ff12af08f4ce928a52bfde9ca77a7689/examples/yolov8/python/convert.py

from rknn.api import RKNN
import kdl
from pathlib import Path
import random

# read config file
with open('../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)
name = config['name'].args[0]
model = config["model"].args[0]
imgsz = int(config["imgsz"].args[0])

model_path = f"../work/{name}.onnx"
platform = 'rk3588'
do_quant = True
output_path = f"../work/{name}-{imgsz}-{imgsz}-{model}.rknn"

# Generate quant-images.txt
# get all images
images = []
for image in Path(f"../work/datasets/{name}/test/images").iterdir():
    if image.suffix == '.jpg':
        images.append(image)
# get 20 random images
select_images = []
while len(select_images)<20:
    select_images.append(images.pop(random.randint(0,len(images)-1)))
# write quant-images.txt
quant_images_path = Path('../work/onnx-to-rknn/quant-images.txt')
quant_images_path.parent.mkdir(parents=True, exist_ok=True)
with open(quant_images_path, 'w', encoding='utf-8') as f:
    for image in select_images:
        f.write(str(image.resolve()))
        f.write('\n')

rknn = RKNN(verbose=True)

# pre-process config
rknn.config(mean_values=[[0,0,0]], std_values=[[255,255,255]], target_platform=platform)

# load model
print('load model...')
ret = rknn.load_onnx(model=model_path)
if ret != 0:
    print('load model failed')
    exit(1)

# build model
print('build model...')
ret = rknn.build(do_quantization=True, dataset=quant_images_path)
if ret != 0:
    print('build model failed')
    exit(2)

# export RKNN
print('export rknn...')
ret = rknn.export_rknn(output_path)
if ret != 0:
    print('export rknn failed')
    exit(3)

print('success!')

rknn.release()
