FROM python:3.11-bookworm

RUN pip install --upgrade pip
RUN pip install uv

RUN mkdir /work

ADD verify-rocm /work/verify-rocm
WORKDIR /work/verify-rocm
RUN uv sync

COPY download-dataset /work/download-dataset
WORKDIR /work/download-dataset
RUN uv sync

COPY train /work/train
WORKDIR /work/train
RUN uv sync

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

COPY onnx-to-rknn /work/onnx-to-rknn
WORKDIR /work/onnx-to-rknn
RUN uv sync

RUN apt update
RUN apt install -y libgl1-mesa-glx

WORKDIR /work
COPY run.sh /work/run.sh
CMD ["/work/run.sh"]
