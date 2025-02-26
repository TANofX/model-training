#!/bin/sh
mkdir -p output
set -ex

docker run \
	--rm \
	--device /dev/kfd --device /dev/dri --security-opt=seccomp=unconfined \
	--shm-size=2gb \
	-v ./config.kdl:/work/config.kdl \
	-v ./output:/output \
	mtu

echo "Generated ./output/best-640-640-yolov8n.rknn"
