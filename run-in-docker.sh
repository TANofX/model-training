#!/bin/sh
docker run \
	--rm -it \
	--device /dev/kfd --device /dev/dri --security-opt=seccomp=unconfined \
	-v ./download-dataset/config.kdl:/work/download-dataset/config.kdl \
	--shm-size=2gb \
	mtu \
	/bin/bash

