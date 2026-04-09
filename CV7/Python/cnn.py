import torch
import torch.nn as nn
import torch.optim as optim
from tqdm import tqdm
import time
import numpy as np

# Importy z tvojho mlp.py (uisti sa, že mlp.py je v rovnakom priečinku)
from mlp import (
    GLOBAL_SEED, BATCH_SIZE, LR, EPOCHS, CLEAN_FORMAT, 
    load_data, train_one_epoch, evaluate, get_device
)

# =============================================================================
# CNN ARCHITEKTÚRY
# =============================================================================

class CNN1(nn.Module):
    """Základná CNN: 2 konvolučné vrstvy"""
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 7 * 7, 128),
            nn.ReLU(),
            nn.Linear(128, 10)
        )

    def forward(self, x):
        return self.classifier(self.features(x))

class CNN2(nn.Module):
    """Hlbšia CNN: 3 konvolučné vrstvy"""
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.AdaptiveAvgPool2d((4, 4))
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 4 * 4, 128),
            nn.ReLU(),
            nn.Linear(128, 10)
        )

    def forward(self, x):
        return self.classifier(self.features(x))

class CNN3(nn.Module):
    """CNN s Dropoutom"""
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.Dropout2d(0.25),
            nn.MaxPool2d(2)
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 7 * 7, 256),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, 10)
        )

    def forward(self, x):
        return self.classifier(self.features(x))

# Mapovanie pre main.py a benchmark
CNN_MODEL_MAP = {
    "CNN1": CNN1,
    "CNN2": CNN2,
    "CNN3": CNN3,
}

# =============================================================================
# LOGIKA EXPERIMENTU
# =============================================================================

def run_cnn_experiment(model_name, n_runs=5, device=None):
    if device is None: device = get_device()
    
    model_class = CNN_MODEL_MAP[model_name]
    train_loader, val_loader, test_loader, _ = load_data()

    results = {
        "train_losses": [], "val_losses": [],
        "train_accs": [], "val_accs": [],
        "test_loss": [], "test_acc": []
    }

    run_bar = tqdm(range(n_runs), desc=f"Celkový progres {model_name}", bar_format=CLEAN_FORMAT)
    
    for run in run_bar:
        torch.manual_seed(GLOBAL_SEED + run)
        model = model_class().to(device)
        optimizer = optim.Adam(model.parameters(), lr=LR)

        tr_losses, va_losses, tr_accs, va_accs = [], [], [], []
        
        for epoch in range(EPOCHS):
            tr_l, tr_a = train_one_epoch(model, train_loader, optimizer, device)
            va_l, va_a = evaluate(model, val_loader, device)
            tr_losses.append(tr_l); va_losses.append(va_l)
            tr_accs.append(tr_a); va_accs.append(va_a)

        te_loss, te_acc = evaluate(model, test_loader, device)
        results["train_losses"].append(tr_losses)
        results["val_losses"].append(va_losses)
        results["train_accs"].append(tr_accs)
        results["val_accs"].append(va_accs)
        results["test_loss"].append(te_loss)
        results["test_acc"].append(te_acc)

    return results