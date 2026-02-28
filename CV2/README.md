# 🧬 CV2 - Globálna optimalizácia a Genetické algoritmy (GA)

Tento priečinok je zameraný na implementáciu a analýzu **genetických algoritmov** ako nástroja pre globálnu optimalizáciu v high-dimensional priestoroch. Na rozdiel od lokálneho hľadania (Hill Climbing), GA pracujú s celou populáciou jedincov naraz, čo umožňuje efektívnejšie prehľadávanie stavového priestoru a únik z lokálnych miním.

## 🔬 Testovacie funkcie

### 1. Nová Schwefelova funkcia (3c)
Používa sa pre základné úlohy a 100-D bonus. Je charakteristická svojou vysokou multimodalitou a prítomnosťou mnohých lokálnych pascí.
* **Definičný obor**: $-1000 < x_i < 1000$.
* **Globálne optimum**: Nachádza sa v bode $x \approx -864.72$ s hodnotou $min F(x) = -792.72 \cdot n$.
* **Parametre**: Implementácia zahŕňa posun $x_0 = 30$ a vertikálny posun $y_0 = 100$.

### 2. Eggholder funkcia (Bonus B)
Extrémne náročná funkcia na optimalizáciu kvôli obrovskému množstvu úzkych a hlbokých lokálnych miním.
* **Rozmer**: Implementované pre 10-D priestor.
* **Definičný obor**: $-500 < x_i < 500$.

---

## 🛠️ Implementované metódy a mechanizmy

### 1. Evolučný cyklus (Základný GA)
Algoritmus simuluje biologickú evolúciu prostredníctvom týchto krokov:
* **Selekcia**: Kombinácia metód `selbest` pre zachovanie elity a `selsus` pre stochastické univerzálne vzorkovanie.
* **Kríženie (Crossover)**: Rekombinácia informácií pomocou funkcie `crossov` s nastaviteľným počtom bodov kríženia.
* **Mutácia**: Implementovaná ako bitová/indexová mutácia (`mutx`) a aditívna mutácia (`muta`) pre jemné doladenie v okolí riešenia.

### 2. Multi-run analýza (Bod 5)
Sledovanie vplyvu hyperparametrov na úspešnosť konvergencie:
* **Dynamické parametre**: V rámci 10 behov sa mení miera mutácie (2% – 10%), počet bodov kríženia a veľkosť elity.
* **Vizualizácia**: Porovnanie konvergencie rôznych nastavení v jednom spoločnom grafe.

### 3. High-Dimensional Optimization (Bonus A)
* Optimalizácia v **100-rozmernom** priestore ($D=100$).
* Vyžaduje zväčšenú populáciu (300 jedincov) a vyššiu agresivitu pri krížení (9-bodový crossover).

---

## 📊 Štruktúra kódov

| Súbor | Popis |
| :--- | :--- |
| `CV2_Bod2.m` | Hlavný skript pre 10-D optimalizáciu Schwefelovej funkcie. |
| `CV2_Bod2_MultiRun.m` | Analýza vplyvu parametrov na 10 rôznych behoch. |
| `testfn3c.m` | Matematická definícia Schwefelovej účelovej funkcie. |
| `CV2_BonusA.m` | Riešenie komplexnej 100-D úlohy s rozšírenou populáciou. |
| `CV2_BonusB.m` | Optimalizácia funkcie Eggholder pomocou `seldiv` a `selrand`. |

---

## 💻 Spustenie

### 🟦 MATLAB
1. Otvorte požadovaný `.m` súbor v prostredí MATLAB.
2. Spustite skript (F5).
3. V príkazovom okne sa zobrazuje progres: `Gen`, `Fitness` a odhadovaný čas do konca (`ETF`).
4. Po skončení sa vygenerujú grafy priebehu fitness v čase.