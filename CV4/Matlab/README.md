# Optimalizácia investičného portfólia pomocou GA (Zadanie 4)

Tento projekt implementuje genetický algoritmus (GA) na riešenie úlohy optimálneho rozdelenia investičného kapitálu v hodnote **10 000 000 EUR**. Program porovnáva tri hlavné penalizačné prístupy a vizualizuje ich schopnosť nájsť prípustné riešenie v ohraničenom stavovom priestore.

---

## 1. Postup riešenia

### Konfigurácia a kódovanie
Riešenie je kódované ako chromozóm s reálnymi číslami o dĺžke $D = 5$. 
Fitness funkcia je definovaná ako minimalizácia záporného výnosu so zahrnutím penalizácie:
$$Fitness = - (0.04x_1 + 0.07x_2 + 0.11x_3 + 0.06x_4 + 0.05x_5) + Pokuta$$

### Metódy pokutovania
Implementované boli tri stratégie spracovania neprípustných jedincov:

1. **Mŕtva pokuta:** Využíva vysokú fixnú sankciu ($10^{12}$). Bol pridaný "navádzací mechanizmus" ($+ \sum v \cdot 10$), ktorý umožňuje algoritmu rozlišovať mieru porušenia aj u "mŕtvych" jedincov.
2. **Stupňovitá pokuta:** Penalizuje jedinca na základe **počtu** porušených ohraničení (fixných $5 \cdot 10^6$ za každé pravidlo).
3. **Úmerná pokuta:** Sankcia rastie lineárne s **veľkosťou** prekročenia limitov (rozdiel medzi hodnotou a limitom).

---

## 2. Archivácia výsledkov (Finálne meranie)

Nižšie sú uvedené dáta z posledného úspešného behu algoritmu (400 generácií, 100 jedincov). Všetky metódy úspešne konvergovali k legálnym riešeniam.

### **A. Metóda: Mŕtva pokuta**
* **x1 (Bežné akcie):** 101 681.91 EUR
* **x2 (Preferenčné akcie):** 2 394 451.24 EUR
* **x3 (Podnikové dlhopisy):** 2 238 094.53 EUR
* **x4 (Štátne dlhopisy):** 2 761 523.90 EUR
* **x5 (Úspory v banke):** 2 504 177.90 EUR
* **Celkový ročný výnos:** **708 769.59 EUR**

### **B. Metóda: Stupňovitá pokuta**
* **x1 (Bežné akcie):** 318 238.90 EUR
* **x2 (Preferenčné akcie):** 1 638 322.00 EUR
* **x3 (Podnikové dlhopisy):** 1 916 867.52 EUR
* **x4 (Štátne dlhopisy):** 3 072 957.97 EUR
* **x5 (Úspory v banke):** 3 053 537.51 EUR
* **Celkový ročný výnos:** **675 321.88 EUR**

### **C. Metóda: Úmerná pokuta**
* **x1 (Bežné akcie):** 401 749.49 EUR
* **x2 (Preferenčné akcie):** 1 980 057.80 EUR
* **x3 (Podnikové dlhopisy):** 2 316 061.65 EUR
* **x4 (Štátne dlhopisy):** 2 665 682.14 EUR
* **x5 (Úspory v banke):** 2 635 087.64 EUR
* **Celkový ročný výnos:** **701 136.12 EUR**


---

## 3. Stabilita konvergencie (Bod 4 zadania)

Pre každú metódu bolo vykonaných **5 nezávislých behov**. Nižšie sú zobrazené priebehy konvergencie (stabilitu riešenia dokumentujú Figure 1 až 3):

| Metóda: Mŕtva pokuta | Metóda: Stupňovitá pokuta | Metóda: Úmerná pokuta |
| :---: | :---: | :---: |
| ![Mrtva](img/mrtva.png) | ![Stupnovita](img/stupnovita.png) | ![Umerna](img/umerna.png) |

### 4. Porovnanie najlepších výsledkov (Bod 6 zadania)

Nasledujúci graf (Figure 4) zobrazuje porovnanie najlepších priebehov konvergencie pre všetky tri testované metódy pokutovania. Tento graf demonštruje, ako rýchlo a k akej finálnej hodnote dokáže daná metóda algoritmus navigovať.

![Porovnanie všetkých metód](img/1.png)

---

## 4. Záver a zhodnotenie
Z výsledkov vyplýva, že najvyšší výnos dosiahla **Mŕtva pokuta** (vďaka navádzaciemu faktoru), tesne nasledovaná **Úmernou pokutou**. 

Algoritmus v oboch prípadoch identifikoval ako kľúčovú investíciu **Podnikové dlhopisy (x3)** s najvyšším úrokom (11 %), pričom ich objem maximalizoval až po hranicu ohraničenia (spolu so štátnymi dlhopismi do 50 % portfólia). Rovnako úspešne dodržal podmienku, kde objem štátnych dlhopisov ($x_4$) musel byť vyšší alebo rovný úsporám v banke ($x_5$).