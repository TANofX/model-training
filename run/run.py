from ultralytics import YOLO
model = YOLO("../best.pt")
# May have to update source (camera)
results = model(source=2, show=True, save=True)
