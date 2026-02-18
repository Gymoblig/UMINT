# 🧠 UMINT - Umelá inteligencia

Tento repozitár slúži na evidenciu a správu riešení zadaní z predmetu Umelá inteligencia (UMINT). Projekt je štruktúrovaný podľa jednotlivých cvičení a obsahuje porovnania implementácií v jazykoch MATLAB a Python. 📈

## 📂 Štruktúra projektu

Projekt je rozdelený na hlavné časti: implementácie úloh (CV), zdieľané knižnice (libs) a podklady k prednáškam.

### Cvičenia
* 🏔️ **[CV1](./CV1)**: Optimalizácia a Hill Climbing (Schwefelova funkcia).
    * [Matlab](./CV1/Matlab): Implementácie v prostredí MATLAB.
    * [Python](./CV1/Python): Portované riešenia v jazyku Python.
* 🛠️ **CV2**: (Pripravuje sa)
* 🛠️ **CV3**: (Pripravuje sa)

### ⚙️ Knižnice a nástroje
* **[libs/Genetic-toolbox](./libs/Genetic-toolbox)** alebo **[https://github.com/STU-FEI-OUI/Genetic-toolbox](https://github.com/STU-FEI-OUI/Genetic-toolbox)**: Nástroje pre prácu s genetickými algoritmami.
* **[libs/UMINT-GA](./libs/UMINT-GA)**  alebo **[https://github.com/STU-FEI-OUI/UMINT-GA](https://github.com/STU-FEI-OUI/UMINT-GA)**: Špecifické knižnice pre evolučné výpočty a testovacie funkcie.

## 📝 Prehľad riešených úloh

### CV1: Lokálna optimalizácia
Zamerané na hľadanie extrémov účelových funkcií v 1D a 2D priestore.
- Vizualizácia Schwefelovej funkcie (testfn3c).
- 🚶 Hill Climbing (deterministický s fixným krokom).
- 🎲 Stochastický Hill Climbing (využitie Gaussovho šumu).
- 🎯 Multi-start stratégia pre nájdenie globálneho minima.

## 💻 Technické požiadavky

### MATLAB
- Vyžiadané základné toolboxy pre optimalizáciu a vizualizáciu (Optimization Toolbox).

### Python
- Verzia 3.8 a vyššia.
- Knižnice: `numpy`, `matplotlib`.

Inštalácia potrebných Python balíkov:
```bash
pip install numpy matplotlib
