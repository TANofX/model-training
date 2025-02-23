import torch
if torch.cuda.is_available():
    print("ROCM is available.")
else:
    print("ROCM is NOT available")
    exit(1)
