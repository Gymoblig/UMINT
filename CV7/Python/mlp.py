import time
import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm  # <--- New Import

import torch
import torch.nn as nn
import torch.optim as optim

from torch.utils.data import DataLoader, random_split
from torchvision import datasets, transforms
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

# ── Globálne konštanty ────────────────────────────────────────────────────
GLOBAL_SEED = 42
BATCH_SIZE  = 64
LR          = 0.001
EPOCHS      = 20
CRITERION   = nn.CrossEntropyLoss()
CLEAN_FORMAT = "    {desc} {percentage:3.0f}% |{bar:30}|"

# =============================================================================
# DEVICE (CUDA ONLY)
# =============================================================================

def get_device(force_cpu=False):
    if force_cpu:
        return torch.device("cpu")
    if torch.cuda.is_available():
        return torch.device("cuda")
    return torch.device("cpu")


# =============================================================================
# ARCHITEKTÚRY
# =============================================================================

class MLP1(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Flatten(),
            nn.Linear(784, 256),
            nn.ReLU(),
            nn.Linear(256, 10)
        )

    def forward(self, x):
        return self.net(x)


class MLP2(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Flatten(),
            nn.Linear(784, 512),
            nn.ReLU(),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Linear(256, 10)
        )

    def forward(self, x):
        return self.net(x)


MODEL_MAP = {
    "MLP1": MLP1,
    "MLP2": MLP2,
}

# =============================================================================
# DÁTA
# =============================================================================

def load_data():
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
    ])

    full_train = datasets.MNIST("./data", train=True, download=True, transform=transform)
    test_set   = datasets.MNIST("./data", train=False, download=True, transform=transform)

    val_size = 6000
    train_size = len(full_train) - val_size

    train_set, val_set = random_split(
        full_train,
        [train_size, val_size],
        generator=torch.Generator().manual_seed(GLOBAL_SEED)
    )

    return (
        DataLoader(train_set, batch_size=BATCH_SIZE, shuffle=True),
        DataLoader(val_set,   batch_size=BATCH_SIZE, shuffle=False),
        DataLoader(test_set,  batch_size=BATCH_SIZE, shuffle=False),
        test_set
    )

# =============================================================================
# TRAIN / EVAL
# =============================================================================

def train_one_epoch(model, loader, optimizer, device):
    model.train()
    total_loss, correct, total = 0, 0, 0

    # Added tqdm for batch-level progress (optional, leave leave=False to keep it clean)
    for X, y in loader:
        X, y = X.to(device), y.to(device)

        optimizer.zero_grad()
        out = model(X)
        loss = CRITERION(out, y)

        loss.backward()
        optimizer.step()

        total_loss += loss.item() * X.size(0)
        correct += (out.argmax(1) == y).sum().item()
        total += X.size(0)

    return total_loss / total, correct / total * 100


def evaluate(model, loader, device):
    model.eval()
    total_loss, correct, total = 0, 0, 0

    with torch.no_grad():
        for X, y in loader:
            X, y = X.to(device), y.to(device)

            out = model(X)
            loss = CRITERION(out, y)

            total_loss += loss.item() * X.size(0)
            correct += (out.argmax(1) == y).sum().item()
            total += X.size(0)

    return total_loss / total, correct / total * 100


# =============================================================================
# EXPERIMENT
# =============================================================================

def run_experiment(model_name, n_runs=5, device=None):
    if device is None:
        device = get_device()
    
    print(f"\n▶ Using device: {device}")
    if device.type == "cuda":
        print("GPU:", torch.cuda.get_device_name(0))

    model_class = MODEL_MAP[model_name]
    train_loader, val_loader, test_loader, test_set = load_data()

    results = {
        "train_losses": [], "val_losses": [],
        "train_accs": [], "val_accs": [],
        "test_loss": [], "test_acc": []
    }

    # Outer bar for Runs
    run_bar = tqdm(range(n_runs), desc="Overall Progress:", unit="run", bar_format=CLEAN_FORMAT)
    
    for run in run_bar:
        torch.manual_seed(GLOBAL_SEED + run)

        model = model_class().to(device)
        optimizer = optim.Adam(model.parameters(), lr=LR)

        tr_losses, va_losses = [], []
        tr_accs, va_accs = [], []

        # Inner bar for Epochs
        epoch_bar = tqdm(range(EPOCHS), desc=f"Run {run+1}:           ", leave=False, bar_format=CLEAN_FORMAT)
        
        for epoch in epoch_bar:
            tr_l, tr_a = train_one_epoch(model, train_loader, optimizer, device)
            va_l, va_a = evaluate(model, val_loader, device)

            tr_losses.append(tr_l)
            va_losses.append(va_l)
            tr_accs.append(tr_a)
            va_accs.append(va_a)

            

        te_loss, te_acc = evaluate(model, test_loader, device)

        results["train_losses"].append(tr_losses)
        results["val_losses"].append(va_losses)
        results["train_accs"].append(tr_accs)
        results["val_accs"].append(va_accs)
        results["test_loss"].append(te_loss)
        results["test_acc"].append(te_acc)

    return results


# =============================================================================
# BENCHMARK
# =============================================================================

def benchmark_cpu_gpu(model_name):
    # 1. Importujeme mapy modelov z oboch modulov
    # Import vo vnútri funkcie zabráni "circular import" problémom
    from mlp import MODEL_MAP as mlp_map
    try:
        from cnn import CNN_MODEL_MAP as cnn_map
    except ImportError:
        cnn_map = {}

    # 2. Spojíme ich do jedného hľadacieho slovníka
    # Teraz tu bude MLP1, MLP2, CNN1, CNN2, CNN3
    all_available_models = {**mlp_map, **cnn_map}

    if model_name not in all_available_models:
        print(f"  Chyba: Model '{model_name}' nebol nájdený.")
        return None

    model_class = all_available_models[model_name]
    train_loader, _, _, _ = load_data()
    
    results = {}
    devices = [("CPU", torch.device("cpu"))]
    if torch.cuda.is_available():
        devices.append(("CUDA", torch.device("cuda")))

    for name, dev in devices:
        torch.manual_seed(GLOBAL_SEED)
        model = model_class().to(dev)
        opt = optim.Adam(model.parameters(), lr=LR)

        start = time.time()
        # Pre benchmark stačí 1 epocha, aby sme videli rozdiel v rýchlosti
        for _ in tqdm(range(1), desc=f"Benchmarking {name}", bar_format=CLEAN_FORMAT):
            train_one_epoch(model, train_loader, opt, dev)

        duration = time.time() - start
        results[name] = duration
        print(f"  {name}: {duration:.2f}s")

    return results


# =============================================================================
# TABLE
# =============================================================================

def print_results_table(results, model_name):
    print(f"\n  ┌─ {model_name} – výsledky jednotlivých behov {'─'*20}┐")
    print(f"  │ {'Beh':>3} │ {'Train loss':>10} │ {'Val loss':>8} │ {'Train acc':>9} │ {'Test acc':>8} │")
    print(f"  ├{'─'*5}┼{'─'*12}┼{'─'*10}┼{'─'*11}┼{'─'*10}┤")
    for i in range(len(results["test_acc"])):
        tr_l = results["train_losses"][i][-1]
        va_l = results["val_losses"][i][-1]
        tr_a = results["train_accs"][i][-1]
        te_a = results["test_acc"][i]
        print(f"  │ {i+1:>3} │ {tr_l:>10.4f} │ {va_l:>8.4f} │ {tr_a:>8.2f}% │ {te_a:>7.2f}% │")
    print(f"  └{'─'*5}┴{'─'*12}┴{'─'*10}┴{'─'*11}┴{'─'*10}┘")

    accs   = results["test_acc"]
    losses = results["test_loss"]
    print(f"\n  Súhrn: min={min(accs):.2f}%  max={max(accs):.2f}%  "
          f"priemer={np.mean(accs):.2f}%  avg_loss={np.mean(losses):.4f}")