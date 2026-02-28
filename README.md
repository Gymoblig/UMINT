# 🧠 UMINT - Umelá inteligencia

Tento repozitár slúži na evidenciu a správu riešení zadaní z predmetu Umelá inteligencia (UMINT). Projekt je štruktúrovaný podľa jednotlivých cvičení a obsahuje porovnania implementácií v jazykoch MATLAB a Python. 📈

## 📂 Štruktúra projektu

Projekt je rozdelený na hlavné časti: implementácie úloh (CV), zdieľané knižnice (libs) a podklady k prednáškam.

### Cvičenia
* 🏔️ **[CV1](./CV1)**: Optimalizácia a Hill Climbing (Schwefelova funkcia).
    * [Matlab](./CV1/Matlab): Implementácie v prostredí MATLAB.
    * [Python](./CV1/Python): Portované riešenia v jazyku Python.
* 🧬 **[CV2](./CV2)**: Globálna optimalizácia a Genetické algoritmy.
    * [Matlab](./CV2): Implementácia genetických algoritmov s využitím toolboxov `selbest`, `selsus`, `crossov`, `mutx`, `muta`.
* 🛠️ **CV3**: (Pripravuje sa)

### ⚙️ Knižnice a nástroje (Python)
* **[https://github.com/STU-FEI-OUI/Genetic-toolbox](https://github.com/STU-FEI-OUI/Genetic-toolbox)**: Nástroje pre prácu s genetickými algoritmami.
* **[https://github.com/STU-FEI-OUI/UMINT-GA](https://github.com/STU-FEI-OUI/UMINT-GA)**: Špecifické knižnice pre evolučné výpočty a testovacie funkcie.

---

## 📝 Prehľad riešených úloh

### CV1: Lokálna optimalizácia
Zamerané na hľadanie extrémov účelových funkcií v 1D a 2D priestore.
- Vizualizácia Schwefelovej funkcie (testfn3c).
- 🚶 Hill Climbing (deterministický s fixným krokom).
- 🎲 Stochastický Hill Climbing (využitie Gaussovho šumu).
- 🎯 Multi-start stratégia pre nájdenie globálneho minima.

### CV2: Globálna optimalizácia (Genetické algoritmy)
Zamerané na evolučné techniky prehľadávania rozsiahlych stavových priestorov.
- 🧬 **Evolučný cyklus**: Implementácia selekcie, kríženia a mutácie pre populácie jedincov.
- 🧪 **Multi-run analýza**: Sledovanie vplyvu hyperparametrov (miera mutácie, body kríženia) na konvergenciu algoritmu.
- 🏗️ **High-dimensional (100-D)**: Optimalizácia komplexných funkcií vo vysokom rozmere.
- 🍳 **Eggholder funkcia**: Riešenie jednej z najťažších testovacích funkcií pre GA v 10-D priestore.
- ⏱️ **Real-time Monitoring**: Výpočet a zobrazovanie progresu a odhadovaného času do konca (ETF).

---

## 💻 Technické požiadavky

### MATLAB
- Vyžadované základné toolboxy pre optimalizáciu a vizualizáciu.
- Pre CV2 sú potrebné funkcie z externého Genetic Toolboxu (`genrpop`, `selbest`, `selsus`, `crossov`, `mutx`, `muta`, `change`).

### Python
- Verzia 3.8 a vyššia.
- Knižnice: `numpy`, `matplotlib`.

Inštalácia potrebných Python balíkov:
```bash
pip install numpy matplotlib
