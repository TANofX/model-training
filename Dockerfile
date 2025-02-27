FROM python:3.11-bookworm

# Install libgl1-mesa-glx, which is needed for the training step
RUN apt-get update && \
	apt-get install -y libgl1-mesa-glx && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* 

# Install uv, which is used for Python dependencies
RUN pip install uv

# install dependencies for download-dataset
COPY download-dataset /work/download-dataset
WORKDIR /work/download-dataset
RUN uv sync

# install dependencies for train
COPY train /work/train
WORKDIR /work/train
RUN uv sync

# install dependencies for export-onnx
COPY export-onnx /work/export-onnx
WORKDIR /work/export-onnx
RUN uv sync

# install dependencies for onnx-to-rknn
COPY onnx-to-rknn /work/onnx-to-rknn
WORKDIR /work/onnx-to-rknn
RUN uv sync

COPY best-640-640-yolov8n-labels.txt /work

# setup to run
WORKDIR /work
COPY docker/run.sh /work/run.sh
CMD ["/work/run.sh"]
