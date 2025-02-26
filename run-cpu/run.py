from ultralytics import YOLO
model = YOLO("../work/best.pt")
# May have to update source (camera)
results = model(source=0, show=True, save=True)
