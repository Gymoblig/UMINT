import torch

print(torch.__version__)
print("XPU backend:", torch.version.xpu)
print("XPU available:", torch.xpu.is_available())