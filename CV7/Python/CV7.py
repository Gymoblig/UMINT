import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader, random_split
import matplotlib.pyplot as plt
import numpy as np
import time

# 1. Nastavenie zariadenia (CPU vs GPU)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Používané zariadenie: {device}")

# 2. Príprava dát (MNIST) [cite: 19, 23, 25]
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

full_train_dataset = datasets.MNIST(root="./data", train=True, download=True, transform=transform)
test_dataset = datasets.MNIST(root="./data", train=False, download=True, transform=transform)

# Rozdelenie tréningových dát na trénovacie a validačné (80/20) [cite: 20, 25]
train_size = 50000
val_size = 10000
train_subset, val_subset = random_split(full_train_dataset, [train_size, val_size])

train_loader = DataLoader(train_subset, batch_size=64, shuffle=True)
val_loader = DataLoader(val_subset, batch_size=64, shuffle=False)
test_loader = DataLoader(test_dataset, batch_size=64, shuffle=False)

# 3. Definícia MLP architektúr [cite: 28, 143, 222]
class MLP1(nn.Module):
    def __init__(self):
        super(MLP1, self).__init__()
        self.flatten = nn.Flatten()
        self.model = nn.Sequential(
            nn.Linear(784, 128),
            nn.ReLU(),
            nn.Linear(128, 10)
        )
    def forward(self, x):
        return self.model(self.flatten(x))

class MLP2(nn.Module):
    def __init__(self):
        super(MLP2, self).__init__()
        self.flatten = nn.Flatten()
        self.model = nn.Sequential(
            nn.Linear(784, 256),
            nn.ReLU(),
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.Linear(128, 10)
        )
    def forward(self, x):
        return self.model(self.flatten(x))

# 4. Funkcia pre trénovanie a vyhodnotenie (5 behov) [cite: 28, 34, 36]
def run_experiment(model_class, name, num_runs=5, epochs=10):
    all_accuracies = []
    best_history = None
    max_acc = 0
    
    print(f"\n{'='*30}\nExperiment: {name}\n{'='*30}")
    
    start_time = time.time()
    
    for run in range(1, num_runs + 1):
        model = model_class().to(device)
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.Adam(model.parameters(), lr=0.001)
        
        history = {'train_loss': [], 'val_loss': []}
        
        for epoch in range(epochs):
            model.train()
            t_loss = 0
            for images, labels in train_loader:
                images, labels = images.to(device), labels.to(device)
                optimizer.zero_grad()
                outputs = model(images)
                loss = criterion(outputs, labels)
                loss.backward()
                optimizer.step()
                t_loss += loss.item()
            
            model.eval()
            v_loss = 0
            with torch.no_grad():
                for images, labels in val_loader:
                    images, labels = images.to(device), labels.to(device)
                    v_loss += criterion(model(images), labels).item()
            
            history['train_loss'].append(t_loss / len(train_loader))
            history['val_loss'].append(v_loss / len(val_loader))
        
        # Testovanie [cite: 47]
        model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for images, labels in test_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        acc = 100 * correct / total
        all_accuracies.append(acc)
        print(f"Beh {run}: Test Accuracy = {acc:.2f}%")
        
        if acc > max_acc:
            max_acc = acc
            best_history = history
            
    end_time = time.time()
    
    # Výpis štatistík pre Tabuľku 4 [cite: 229, 230]
    print(f"\nŠtatistiky pre {name}:")
    print(f"Min: {min(all_accuracies):.2f}%")
    print(f"Max: {max(all_accuracies):.2f}%")
    print(f"Priemer: {np.mean(all_accuracies):.2f}%")
    print(f"Celkový čas: {(end_time - start_time)/60:.2f} s")
    
    return best_history, all_accuracies

# 5. Spustenie experimentov [cite: 28]
hist1, accs1 = run_experiment(MLP1, "MLP1 (128)")
hist2, accs2 = run_experiment(MLP2, "MLP2 (256, 128)")

# 6. Vykreslenie grafov (Loss vs Epoch) [cite: 36, 46, 76]
def plot_loss(history, title):
    plt.figure(figsize=(8, 5))
    plt.plot(history['train_loss'], label='Trénovacia chyba (Train Loss)')
    plt.plot(history['val_loss'], label='Validačná chyba (Val Loss)')
    plt.title(f'Priebeh učenia - {title}')
    plt.xlabel('Epocha')
    plt.ylabel('Loss')
    plt.legend()
    plt.grid(True)
    plt.show()

plot_loss(hist1, "MLP1")
plot_loss(hist2, "MLP2")