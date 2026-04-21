# =============================================================================
# main.py  –  UMINT Zadanie 7  |  MNIST: MLP vs. CNN (Final Verified)
# =============================================================================

import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix
import torch

# ── Farby (ANSI) ─────────────────────────────────────────────────────────────
R, B, DIM = "\033[0m", "\033[1m", "\033[2m"
CY, YL, GR, RD = "\033[96m", "\033[93m", "\033[92m", "\033[91m"
WIDTH = 70

def clr():
    os.system("cls" if os.name == "nt" else "clear")

def pause():
    input(f"\n  {DIM}[ Stlač Enter pre návrat do menu ]{R}")

def draw_header(title="UMINT - ZADANIE 7"):
    print(f"\n  {B}{title}{R}")
    print(f"  {DIM}{'─' * WIDTH}{R}")

# =============================================================================
# POMOCNÉ FUNKCIE (Dokumentácia, Benchmark, Vizuálny Test)
# =============================================================================

def document_best_result(results, model_name, device):
    """Generuje grafy a kontingenčnú maticu pre najlepší beh."""
    from mlp import load_data, MODEL_MAP
    try: from cnn import CNN_MODEL_MAP
    except: CNN_MODEL_MAP = {}
    
    all_maps = {**MODEL_MAP, **CNN_MODEL_MAP}
    best_run_idx = np.argmax(results["test_acc"])
    best_acc = results["test_acc"][best_run_idx]
    
    print(f"\n  {GR}✔ Dokumentujem najlepší výsledok pre {model_name}:{R} Beh č. {best_run_idx+1} ({best_acc:.2f}%)")
    
    # 1. Priebeh učenia
    t_loss, v_loss = results["train_losses"][best_run_idx], results["val_losses"][best_run_idx]
    t_acc, v_acc = results["train_accs"][best_run_idx], results["val_accs"][best_run_idx]
    epochs = range(1, len(t_loss) + 1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle(f'Najlepší beh - {model_name}', fontsize=14)
    ax1.plot(epochs, t_loss, label='Train'); ax1.plot(epochs, v_loss, label='Val'); ax1.set_title('Loss'); ax1.legend()
    ax2.plot(epochs, t_acc, label='Train'); ax2.plot(epochs, v_acc, label='Val'); ax2.set_title('Accuracy'); ax2.legend()
    plt.show()

    # 2. Kontingenčná matica
    model = all_maps[model_name]().to(device)
    _, _, test_loader, _ = load_data()
    model.eval()
    all_preds, all_labels = [], []
    with torch.no_grad():
        for imgs, lbls in test_loader:
            imgs = imgs.to(device)
            all_preds.extend(torch.argmax(model(imgs), dim=1).cpu().numpy())
            all_labels.extend(lbls.numpy())

    plt.figure(figsize=(8, 6))
    sns.heatmap(confusion_matrix(all_labels, all_preds), annot=True, fmt='d', cmap='Greens')
    plt.title(f'Matica: {model_name}')
    plt.ylabel('Skutočnosť'); plt.xlabel('Predikcia')
    plt.show()

def visual_test(model_name, device):
    """Zobrazí reálnu vzorku, predikciu a výstupné pravdepodobnosti."""
    from mlp import load_data, MODEL_MAP
    try: from cnn import CNN_MODEL_MAP
    except: CNN_MODEL_MAP = {}
    all_maps = {**MODEL_MAP, **CNN_MODEL_MAP}
    
    _, _, test_loader, _ = load_data()
    model = all_maps[model_name]().to(device)
    model.eval()
    
    images, labels = next(iter(test_loader))
    with torch.no_grad():
        out = model(images.to(device))
        probs = torch.nn.functional.softmax(out, dim=1)
        preds = torch.argmax(out, dim=1)

    clr(); draw_header(f"VIZUÁLNY TEST: {model_name}")
    for i in range(2): # Zobrazíme 2 vzorky
        img = images[i].numpy().squeeze()
        print(f"\n  Vzorka č. {i+1}:")
        for row in img[::2, ::2]:
            print("  " + "".join(["@@" if p > 0.5 else "  " for p in row]))
        
        print(f"  {B}Skutočnosť:{R} {labels[i].item()} | {B}Predikcia:{R} {preds[i].item()}")
        print(f"  {DIM}Výstupy: " + " ".join([f"{j}:{p:.2f}" for j, p in enumerate(probs[i])]) + R)
    pause()

def show_summary(results, type_name, device):
    clr()
    print(f"\n  {B}{CY}▶ FINÁLNE POROVNANIE {type_name}{R}")
    print(f"  {DIM}{'─' * WIDTH}{R}")
    print(f"  {'Model':<10} │ {'Min Acc':>10} │ {'Max Acc':>10} │ {'Avg Acc':>10} │ {'Avg Loss':>10}")
    print(f"  {DIM}{'─' * 10}─┼─{'─' * 10}─┼─{'─' * 10}─┼─{'─' * 10}─┼─{'─' * 10}{R}")
    for name, r in results.items():
        accs, loss = r["test_acc"], r["test_loss"]
        print(f"  {name:<10} │ {min(accs):>9.2f}% │ {max(accs):>9.2f}% │ {np.mean(accs):>9.2f}% │ {np.mean(loss):>10.4f}")
    
    ans = input(f"\n  {YL}Zdokumentovať najlepšie výsledky (Grafy+Matice)? (y/n):{R} ").lower()
    if ans == 'y':
        for name in results.keys(): document_best_result(results[name], name, device)
    pause()

def run_benchmark_visual(model_name):
    from mlp import benchmark_cpu_gpu
    clr(); print(f"\n  {B}{CY}▶ TEST: CPU vs GPU ({model_name}){R}")
    times = benchmark_cpu_gpu(model_name)
    if times and len(times) >= 2:
        vals = list(times.values())
        print(f"\n  {GR}Výsledok:{R} GPU je {B}{vals[0]/vals[1]:.1f}x{R} rýchlejšie.")
    pause()

# =============================================================================
# SUB-MENÁ
# =============================================================================

def menu_cnn():
    from cnn import run_cnn_experiment
    from mlp import print_results_table, get_device
    device, res = get_device(), {}
    while True:
        clr(); draw_header("KONVOLUČNÉ SIETE (CNN)")
        print(f"  {GR}[1-3]{R} Modely | {GR}[4]{R} Všetky | {YL}[B]{R} Benchmark | {YL}[T]{R} Vizuálny Test | {RD}[0]{R} Späť")
        choice = input(f"\n  {B}Voľba:{R} ").strip().upper()
        if choice == "0": break
        if choice == "B": run_benchmark_visual("CNN1"); continue
        if choice == "T": visual_test("CNN1", device); continue
        
        models = ["CNN1", "CNN2", "CNN3"] if choice == "4" else [f"CNN{choice}"] if choice in "123" else []
        for m in models:
            clr(); print(f"\n  {B}{CY}▶ Trénujem {m}...{R}")
            res[m] = run_cnn_experiment(m, n_runs=5, device=device)
            print_results_table(res[m], m); pause()
        if choice == "4" and res: show_summary(res, "CNN", device)

def menu_mlp():
    from mlp import run_experiment, print_results_table, get_device
    device, res = get_device(), {}
    while True:
        clr(); draw_header("VIACVRSTVOVÝ PERCEPTRÓN (MLP)")
        print(f"  {GR}[1-2]{R} Modely | {GR}[3]{R} Obe | {YL}[B]{R} Benchmark | {YL}[T]{R} Vizuálny Test | {RD}[0]{R} Späť")
        choice = input(f"\n  {B}Voľba:{R} ").strip().upper()
        if choice == "0": break
        if choice == "B": run_benchmark_visual("MLP1"); continue
        if choice == "T": visual_test("MLP1", device); continue

        models = ["MLP1", "MLP2"] if choice == "3" else [f"MLP{choice}"] if choice in "12" else []
        for m in models:
            clr(); print(f"\n  {B}{CY}▶ Trénujem {m}...{R}")
            res[m] = run_experiment(m, n_runs=5, device=device)
            print_results_table(res[m], m); pause()
        if choice == "3" and res: show_summary(res, "MLP", device)

def main():
    if os.name == 'nt': os.system('mode con: cols=105 lines=35')
    while True:
        clr(); draw_header("UMINT - ZADANIE 7: JEBNE MAAAA")
        print(f"  {GR}[1]{R} MLP modely\n  {GR}[2]{R} CNN modely\n\n  {RD}[0]{R} Koniec")
        c = input(f"\n  {B}Voľba:{R} ").strip()
        if c == "0": sys.exit(0)
        elif c == "1": menu_mlp()
        elif c == "2": menu_cnn()

if __name__ == "__main__":
    main()


