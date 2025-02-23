from ultralytics import YOLO
model = YOLO("../export-rknn/best-rk3588.rknn")
# May have to update source (camera)
results = model(source=0, stream=True, imgsz=640, conf=0.25, save=False, show=True)
