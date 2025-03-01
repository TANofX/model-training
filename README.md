# Training object detection models to run on an Orange Pi 5 Plus

Instructions for training object detection models on an amd64 computer with an AMD GPU that supports ROCM,
producing a model that will run in PhotonVision on a device with a Rockchip RK3588 ARM SoC with an NPU.

Tested training a computer with an AMD Radeon RX 6600XT, using Debian Bookworm.

Tested running the model on an Orange Pi 5 Plus, using the image from PhotonVision.

Each of many steps (e.g.: downloading models, training models, converting models) requires
different libraries which may have different dependencies, so they are all managed separately
via [uv](https://docs.astral.sh/uv/getting-started/installation/).
This is automated by the scripts provided here. Just follow the instructions below.
People have tried to do this with Jupyter Notebooks, but it is very hard to make that reproducible.

This project is still undergoing rapid development. Things that will hopefully change soon:

* Customize name of model instead of using `best` and generate matching labels file.
* Instructions for creating a model in Roboflow.
* Instructions for using a model not from Roboflow.
* Instructions for using CUDA on Nvidia cards.

## Prerequisites

1. Enable ROCM (for AMD GPUs)
    1. Install `amdgpu` per https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/amdgpu-install.html
        * For `amdgpu-install`'s `--usecase` argument, include at least `hiplibsdk` and `rocm`.
    2. reboot

## Instructions

1. Install python 3.11+ and [uv](https://docs.astral.sh/uv/getting-started/installation/)
2. Build a model in Roboflow
3. Configure `config.kdl`
    1. `cp config.kdl.example config.kdl`
    2. edit `config.kdl`
4. `run.sh`
    * Generates `./work/best-640-640-yolov8n.rknn`
5. Upload model to PhotonVision
    * `work/best-640-640-yolov8n.rknn`
    * `best-640-640-yolov8n-labels.txt`

## Instructions using Docker

1. Install docker
2. Build a model in Roboflow
3. Configure `config.kdl`
    1. `cp config.kdl.example config.kdl`
    2. edit `config.kdl`
4. Build the docker image. Warning: the docker image will be 30+ GB.
    1. `docker build . -t model-training`
5. Run the docker image.
    1. `./run-in-docker.sh`
        * Each run of this step uses a fresh environment, so make a new model,
          update `config.kdl`, and run this step again.
6. Upload model to PhotonVision
    * `output/best-640-640-yolov8n.rknn`
    * `output/best-640-640-yolov8n-labels.txt`

## Run a model on a computer without an NPU

1. `cd run-cpu`
2. `uv sync`
3. `uv run run.py <path_to_model.pt> <camera_num>`
    * E.g.: if you ran `run.sh` above to build the model and you have one camera:
      `uv run run.py ../work/best.pt 0`
    * If running on Wayland, you man need to set `$QT_QPA_PLATFORM` to `xcb`.

## References

* https://docs.ultralytics.com/integrations/rockchip-rknn/
* https://docs.ultralytics.com/quickstart/
* https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/wsl/install-pytorch.html

## Thanks

* Thanks to [Sam Freund](https://github.com/samfreund) for help on the PhotonVision Discord.
