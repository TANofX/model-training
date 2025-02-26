#!/bin/sh
find ../work/dataset/test/images/ -name "*.jpg" \
	| sort --random-sort \
	| head -n 20 \
	> ../work/quant-images.txt
