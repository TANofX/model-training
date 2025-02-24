# Training object detection models to run on an Orange Pi 5 Plus

Instructions for training object detection models on an amd64 computer with an AMD GPU that supports ROCM,
producing a model that will run in PhotonVision on a device with a Rockchip RK3588 ARM SoC with an NPU.

Tested training a computer with an AMD Radeon RX 6600XT, using Debian Bookworm.

Model training done on a amd64 computer with an AMD GPU that supports ROCM.

Tested running the model on an Orange Pi 5 Plus, using the official Debian image.

## Notes

* Pipenv has bugs regarding resolving dependencies from multiple sources, and pytorch has issues with version
  compatibilities. When installing anything alongside torch that exists in http://download.pytorch.org/whl/rocm6.2.4,
  specify it to come from that source. E.g.: `train/Pipfile` gets `tqdm` and `numpy` from `pytorch`.
* Different steps require different transitive dependencies, so each step that uses Python has its own `Pipfile`.
  Trying to do this in a Jupyter Notebook would be a disaster of version conflicts.

## Instructions

1. Create a model in Roboflow
    1. TODO
2. Set up computer to train model
    1. Install python 3.11
    2. Install pipenv
    3. Enable ROCM (for AMD GPUs)
        1. Install `amdgpu` per https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/amdgpu-install.html
        2. sudo amdgpu-install --usecase=hiplibsdk,rocm
        3. reboot
        4. Verify Torch can use ROCM
            1. `pushd verify-rocm`
            2. `pipenv sync`
            3. `pipenv run python3 verify-rocm.py`
                * Should output "ROCM is available".
            4. `popd`
3. Download dataset from Roboflow to `./dataset`.
    1. `push download-dataset`
    2. Create a configuration file for the download script:
        1. `cp config.kdl.example config.kdl`
        2. Edit `config.kdl` and set your values.
    3. Install the dependencies for the download script:
        1. `pipenv sync`
    4. Run the download script:
        1. `pipenv run python3 download-dataset.py`
    5. `popd`
4. Train the model
    1. `pushd train`
    2. `pipenv sync`
    3. `pipenv run ./train.sh`
    4. `cp output/train/weights/best.pt ..`
        * This is the generated model.
    5. `popd`
5. Run object detection on computer
    1. `pushd run-cpu`
    2. `pipenv sync`
    3. `pipenv run python3 run.py`
        * On Wayland, you may need to run `pipenv run env QT_QPA_PLATFORM=xcb python3 run.py`
        * In `run.py`, `source=0` means use the first camera. Change `0` to use a different camera.
6. export to RKNN without quantization
    (This will *not* run in PhotonVision. Skip to step 8 if you want to use PhotonVision.)
    1. `pushd export-rknn`
    2. `pipenv sync`
    3. `pipenv run yolo export model=../best.pt format=rknn name=rk3588`
    4. `mv best-rk3588.rknn best_rknn_model/`
    5. `mv best_rknn_model ../run-rknn/`
    6. `popd`
7. run non-quantized on RKNN device (e.g.: Orange Pi 5 Plus)
    1. http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-5-plus.html
    2. `pushd run-rknn`
    3. `sudo cp librknnrt.so /usr/lib/` (only do this one time per Orange Pi)
        * `librknnrt.so` is from https://github.com/airockchip/rknn-toolkit2/blob/master/rknpu2/runtime/Linux/librknn_api/aarch64/librknnrt.so
    4. `pipenv run yolo predict model=../export-rknn/best_rknn_model source=0`
8. Export to RKNN with quantization so it can run in Photonvision.
    1. Export to modified ONNX (This step relies on a fork of ultralytics, and does not have a version lock file, so this may break in the future. Good luck!)
        1. `pushd export-onnx`
        2. `virtualenv venv`
        3. `source venv bin activate` (This might be different if you do not use bash.)
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
            * Should have generated `../best.onnx`
        11. `deactivate`
        12. `popd`
    2. Convert ONNX to RKNN with quantization
        1. `pushd onnx-to-rknn`
        2. `./gen-quant-images-txt.sh`
        3. `pipenv sync`
        4. `pipenv run python3 convert.py`

## References

* https://docs.ultralytics.com/integrations/rockchip-rknn/
* https://docs.ultralytics.com/quickstart/
* https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/wsl/install-pytorch.html

## Thanks

* Thanks to [Sam Freund](https://github.com/samfreund) for help on the PhotonVision Discord.
