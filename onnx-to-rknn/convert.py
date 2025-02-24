#!/usr/bin/env python
# Adapted from https://github.com/airockchip/rknn_model_zoo/blob/cc541636ff12af08f4ce928a52bfde9ca77a7689/examples/yolov8/python/convert.py

from rknn.api import RKNN

# args: ../best.onnx rk3588 i8 ../best.rknn

model_path = '../best.onnx'
platform = 'rk3588'
do_quant = True
output_path = '../best-640-640-yolov8n.rknn'
dataset_path = 'quant-images.txt'

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
ret = rknn.build(do_quantization=True, dataset=dataset_path)
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
