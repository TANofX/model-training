import sys
from ultralytics import YOLO
# Arguments: path_to_model camera_source_number
model = YOLO(sys.argv[1])
results = model(source=int(sys.argv[2]), show=True, save=True)
