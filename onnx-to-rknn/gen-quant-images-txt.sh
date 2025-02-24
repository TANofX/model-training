#!/bin/sh
find ../dataset/test/images/ -name "*.jpg"|sort --random-sort |head -n 20 > quant-images.txt
