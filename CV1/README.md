# 🏔️ CV1 - Lokálna optimalizácia a Hill Climbing

Tento priečinok je zameraný na základy matematickej optimalizácie a implementáciu algoritmov pre hľadanie extrémov (miním) nelineárnych funkcií. Hlavným cieľom je pochopiť správanie algoritmov v členitom teréne s mnohými lokálnymi extrémami.

## 🔬 Testovacia funkcia: Schwefel 3c

Pre všetky úlohy používame modifikovanú Schwefelovu funkciu. Táto funkcia je v oblasti umelej inteligencie a evolučných výpočtov populárna, pretože je **multimodálna** – obsahuje veľké množstvo lokálnych miním, ktoré môžu algoritmus "uväzniť" predtým, než nájde to globálne.

### Matematická definícia
$$f(x) = \sum_{i=1}^{n} ( -(x_i - x_0) \cdot \sin(\sqrt{|x_i - x_0|}) + y_0 )$$

**Parametre v našej implementácii:**
- 🎯 **Posun $x_0 = 30$**: Posúva globálne minimum mimo stred súradnicovej sústavy.
- 📐 **Vertikálny posun $y_0 = 100$**: Zvyšuje celkovú hodnotu fitness.
- 🌐 **Globálne optimum**: Nachádza sa približne v bode $x \approx -864.72$.



---

## 🛠️ Implementované metódy

### 1. Deterministický Hill Climbing (Fixný krok)
Základná verzia algoritmu "horolezec". 
- **Logika**: Algoritmus sa pozrie vľavo a vpravo o pevnú vzdialenosť $d$. Ak je niektorý zo susedov lepší, presunie sa tam.
- **Limitácia**: Ak je krok $d$ príliš malý, algoritmus sa zasekne v najbližšej "jame" (lokálnom minime). Ak je príliš veľký, môže preskočiť úzke globálne minimum.

### 2. Stochastický Hill Climbing (Bonus A)
Vylepšená verzia, ktorá namiesto fixného smeru a kroku využíva náhodu.
- **Logika**: Nový kandidát sa generuje ako $x_{new} = x_{curr} + d \cdot \text{randn()}$.
- **Výhoda**: Vďaka Gaussovmu rozdeleniu (náhodný šum) môže algoritmus robiť rôzne dlhé skoky, čo mu občas umožní uniknúť z plytkých lokálnych miním.

### 3. Multi-start stratégia
Keďže Schwefelova funkcia je zradná, jedno spustenie málokedy nájde globálne minimum.
- **Logika**: Algoritmus sa spustí $N$-krát (napr. 30-krát), pričom každý štart začína na náhodnej pozícii v rámci definičného oboru.
- **Cieľ**: Zozbierať výsledky zo všetkých behov a vybrať ten absolútne najlepší (Global Best).

---

## 📊 Vizualizácia v 2D priestore (Bonus B)

V bonusovej úlohe B rozširujeme problém do dvoch dimenzií ($x, y$). Účelová funkcia sa stáva súčtom príspevkov oboch súradníc: $F(x, y) = f(x) + f(y)$.



- **Vizualizácia**: Vykresľujeme 3D povrch (Surface plot), po ktorom sa pohybujú jednotliví agenti.
- **Trajektórie**: Červené čiary v grafe znázorňujú cestu, ktorou sa algoritmus "kotúľal" do údolia.

---

## 💻 Spustenie úloh

### 🟦 MATLAB
Súbory spustíte priamo v editore MATLAB. Pre 3D vizualizáciu je dôležitý súbor `CV1_BonusB.m`, ktorý vyžaduje grafickú podporu pre `surf` a `plot3`.

### 🟨 Python
Python verzie vyžadujú knižnice `numpy` pre matematické operácie a `matplotlib` pre grafy.
```bash
python CV1_Uloha2.py  # Spustí 1D Multi-start Hill Climbing
