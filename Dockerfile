FROM python:3.11-bookworm

# Install libgl1-mesa-glx, which is needed for the training step
RUN apt-get update && \
	apt-get install -y libgl1-mesa-glx && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* 

# Install uv, which is used for Python dependencies
RUN pip install uv

# install dependencies for verify-rocm
ADD verify-rocm /work/verify-rocm
WORKDIR /work/verify-rocm
RUN uv sync

# install dependencies for download-dataset
COPY download-dataset /work/download-dataset
WORKDIR /work/download-dataset
RUN uv sync

# install dependencies for train
COPY train /work/train
WORKDIR /work/train
RUN uv sync

# install dependencies for export-onnx
# TODO do this with uv
RUN pip install virtualenv
RUN mkdir /work/export-onnx && \
	cd /work/export-onnx && \
	virtualenv venv && \
	. venv/bin/activate && \
	git clone https://github.com/airockchip/ultralytics_yolov8 ultralytics && \
	cd ultralytics && \
	git checkout 4674fe6e && \
	pip install -e . && \
	pip install onnx==1.17.0

# install dependencies for onnx-to-rknn
COPY onnx-to-rknn /work/onnx-to-rknn
WORKDIR /work/onnx-to-rknn
RUN uv sync

# setup to run
WORKDIR /work
COPY run.sh /work/run.sh
CMD ["/work/run.sh"]
