# Training object detection models to run on an Orange Pi 5 Plus

Instructions for training object detection models to run on an Orange Pi 5 Plus.

Model training done on a amd64 computer with an AMD GPU that supports ROCM.
(Tested on a Radeon RX 6600XT.)

## Instructions

1. Prerequisites
    1. Install python 3.11
    2. Install pipenv
    3. Enable ROCM (for AMD GPUs) (tested on Debian Bookworm)
        1. `wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/jammy/amdgpu-install_6.3.60303-1_all.deb`
        2. `sudo dpkg -i amdgpu-install_6.3.60303-1_all.deb`
        3. `sudo amdgpu-install --usecase=hiplibsdk,rocm`
        4. `reboot`
        5. Verify Torch can use ROCM
            1. `pushd verify-rocm`
            2. `pipenv install`
            3. `pipenv run python3 verify-rocm.py`
                * Should output "CUDA is available".
            4. `popd`
2. Download dataset from Roboflow to `./dataset`.
    1. `push download-dataset`
    2. Create a configuration file for the download script:
        1. `cp config.kdl.example config.kdl`
        2. Edit `config.kdl` and set your values.
    3. Install the dependencies for the download script:
        1. `pipenv install`
    4. Run the download script:
        1. `pipenv run python3 download-dataset.py`
    5. `popd`
3. Train the model
    1. `pushd train`
    2. `pipenv install`
    3. `pipenv run ./train.sh`
    4. `cp output/train/weights/best.pt ..`
        * This is the generated model.
    4. `popd`
4. run on computer
    1. `pushd run-cpu`
    2. `pipenv install`
    3. `pipenv run python3 run.py`
        * On Wayland, you may need to do `pipenv run env QT_QPA_PLATFORM=xcb python3 run.py`
5. export to RKNN
    1. `pushd export-rknn`
    2. `pipenv install`
    3. `pipenv run yolo export model=best.pt format=rknn name=rk3588`
    4. `mv best-rk3588.rknn best_rknn_model`
    5. `popd`
6. run on RKNN
    1. `pushd run-rknn`
    2. `sudo cp librknnrt.so /usr/lib/` (only do this one time per Orange Pi)
        * `librknnrt.so` is from https://github.com/airockchip/rknn-toolkit2/blob/master/rknpu2/runtime/Linux/librknn_api/aarch64/librknnrt.so
    3. `pipenv run yolo predict model=../export-rknn/best_rknn_model source=0`

## References

* https://docs.ultralytics.com/integrations/rockchip-rknn/
* https://docs.ultralytics.com/quickstart/
* https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/wsl/install-pytorch.html
