# Training object detection models to run on an Orange Pi 5 Plus

Instructions for training object detection models on an amd64 computer with an AMD GPU that supports ROCM,
producing a model that will run in PhotonVision on a device with a Rockchip RK3588 ARM SoC with an NPU.

Tested training a computer with an AMD Radeon RX 6600XT, using Debian Bookworm.

Tested running the model on an Orange Pi 5 Plus, using the image from PhotonVision.

This project is still undergoing rapid development. Things that will hopefully change soon:

* More configuration of training parameters in `config.kdl`
* Customize name of model instead of using `best`.
* Completely stop using `pipenv`.
* Instructions for creating a model in Roboflow.
* Instructions for using a model not from Roboflow.

## Instructions

1. Create a model in Roboflow
    1. TODO
2. Set up computer to train model
    1. Install Docker.
    2. Enable ROCM (for AMD GPUs)
        1. Install `amdgpu` per https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/amdgpu-install.html
            * For `amdgpu-install`'s `--usecase` argument, include at least `hiplibsdk` and `rocm`.
        2. reboot
3. Build the docker image. Warning: the docker image will be 50+ GB.
    1. `docker build . -t model-training`
4. Run the docker image.
    1. Create a configuration file:
        1. `cp config.kdl.example config.kdl`
        2. Edit `config.kdl` and set your configuration.
    2. `./run-in-docker.sh`
        * Each run of this step uses a fresh environment, so make a new model,
          update `config.kdl`, and run this step again.
5. Upload model to PhotonVision
    * `output/output/best-640-640-yolov8n.rknn`
    * `best-640-640-yolov8n-labels.txt`

## Detailed instructions if not using Docker

These instructions are for going step-by-step.
They are intended for development of this package;
for actually training models the instructions above that use Docker are recommended.

Each of many steps (e.g.: downloading models, training models, converting models) requires
different libraries which may have different dependencies, so they are all managed separately
(via `uv` or `pipenv`). People have tried to do this with Jupyter Notebooks, but it is very
hard to make that reproducible.

1. Create a model in Roboflow
    1. TODO
2. Set up computer to train model
    1. Install python 3.11
    2. Install [uv](https://docs.astral.sh/uv/getting-started/installation/)
    3. Install pipenv (still required, but working on switching everything to `uv`)
    4. Enable ROCM (for AMD GPUs)
        1. Install `amdgpu` per https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/amdgpu-install.html
        2. sudo amdgpu-install --usecase=hiplibsdk,rocm
        3. reboot
        4. Verify Torch can use ROCM
            1. `pushd verify-rocm`
            2. `uv sync`
            3. `uv run verify-rocm.py`
                * Should output "ROCM is available".
            4. `popd`
3. Set configuration.
    1. `cp config.kdl.example config.kdl`
    2. Edit `config.kdl` and set your configuration.
4. Download dataset from Roboflow to `./dataset`.
    1. `push download-dataset`
    2. Install the dependencies for the download script:
        1. `uv sync`
    3. Run the download script:
        1. `uv run download-dataset.py`
    4. `popd`
5. Train the model
    1. `pushd train`
    2. `uv sync`
    3. `uv run ./train.sh`
    4. `cp output/train/weights/best.pt ..`
        * This is the generated model.
    5. `popd`
6. Run object detection on computer
    1. `pushd run-cpu`
    2. `pipenv sync`
    3. `pipenv run python3 run.py`
        * On Wayland, you may need to run `pipenv run env QT_QPA_PLATFORM=xcb python3 run.py`
        * In `run.py`, `source=0` means use the first camera. Change `0` to use a different camera.
7. export to RKNN without quantization
    (This will *not* run in PhotonVision. Skip to step 8 if you want to use PhotonVision.)
    1. `pushd export-rknn`
    2. `pipenv sync`
    3. `pipenv run yolo export model=../best.pt format=rknn name=rk3588`
    4. `mv best-rk3588.rknn best_rknn_model/`
    5. `mv best_rknn_model ../run-rknn/`
    6. `popd`
8. run non-quantized on RKNN device (e.g.: Orange Pi 5 Plus)
    1. http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-5-plus.html
    2. `pushd run-rknn`
    3. `sudo cp librknnrt.so /usr/lib/` (only do this one time per Orange Pi)
        * `librknnrt.so` is from https://github.com/airockchip/rknn-toolkit2/blob/master/rknpu2/runtime/Linux/librknn_api/aarch64/librknnrt.so
    4. `pipenv run yolo predict model=../export-rknn/best_rknn_model source=0`
        * Tested on an Orange Pi 5 Plus, using the Debian Bookworm image.
9. Export to RKNN with quantization so it can run in Photonvision.
    1. Export to modified ONNX (This step relies on a fork of ultralytics, and does not have a version lock file, so this may break in the future. Good luck!)
        1. `pushd export-onnx`
        2. `virtualenv venv`
        3. `source venv/bin/activate` (This might be different if you do not use bash.)
        4. `git clone https://github.com/airockchip/ultralytics_yolov8 ultralytics`
            * This is the fork of ultralytics. We will at least go to a known working commit.
            * We should probably use a git submodule for this.
        5. `pushd ultralytics`
        6. `git checkout 4674fe6e` (`origin/main` at time of writing)
        7. `pip install -e .`
            * This is probably not 100% reproducible.
        8. `popd ..`
        9. `pip install onnx==1.17.0`
        10. `yolo mode=export format=rknn model=../best.pt`
            * This has `format=rknn` even though it is creating ONNX. See the ulralytics fork diff for details.
            * Should have generated `../../best.onnx`
        11. `deactivate`
        12. `popd`
    2. Convert ONNX to RKNN with quantization
        1. `pushd onnx-to-rknn`
        2. `./gen-quant-images-txt.sh`
        3. `pipenv sync`
        4. `pipenv run python3 convert.py`
            * Should have generated `../best-640-640-yolov8n.rknn`

## References

* https://docs.ultralytics.com/integrations/rockchip-rknn/
* https://docs.ultralytics.com/quickstart/
* https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/wsl/install-pytorch.html

## Thanks

* Thanks to [Sam Freund](https://github.com/samfreund) for help on the PhotonVision Discord.
