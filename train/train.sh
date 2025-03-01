#!/bin/sh

# This script sets up the environment and then calls train.py

# Needed for RX 6600 XT
# TODO: make this configurable
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Python developers seem to be uniformly bad at handling file paths.
# This is either the result of or the cause of Python introducing a new
# path handling API every other minor version.

# The data.yaml that we get from Roboflow assumes paths are relative
# to the parent directory of data.yaml.

# Ultralytics, by default, writes settings to ~/.config/Ultralytics,
# which is terrible because there are model-specific file paths in there.

# So we can make a temp dir for train.py to run in, and make a config dir there.

# Save absolute path to train.py
TRAIN_PY=$(readlink -f $(dirname "$0"))/train.py

BASE_DIR=$(readlink -f $(dirname $0)/..)
RUN_DIR="${BASE_DIR}/work/tmp/train"
rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}"
cd "${RUN_DIR}"
export YOLO_CONFIG_DIR=yolo-config
mkdir "${YOLO_CONFIG_DIR}"

# Run the training
python3 "${TRAIN_PY}"
