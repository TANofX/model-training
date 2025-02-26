from ultralytics import YOLO

model = YOLO("../work/best.pt")

model.export(format="rknn", imgsz=640, int8=True, dataset="../work/dataset/data.yaml", device=0)

quant_code = "i8"
yolo export model=../work/best.pt format=rknn name=rk3588`
