# Alokácia investícií do finančných produktov pomocou GA (Zadanie 4)

Tento projekt implementuje genetický algoritmus (GA) v prostredí MATLAB na riešenie úlohy optimálneho rozdelenia investičného kapitálu v hodnote **10 000 000 EUR**. Cieľom je maximalizovať odhadovaný ročný výnos pri striktnom dodržaní finančných ohraničení.

## 1. Cieľ úlohy
Hlavným cieľom je navrhnúť a otestovať GA pre výpočet optimálnej alokácie kapitálu do piatich finančných produktov a porovnať vplyv rôznych penalizačných mechanizmov na stabilitu a rýchlosť hľadania riešenia.

* **Porovnávacie kritérium:** Vplyv mŕtvej, stupňovitej a úmernej pokuty na priebeh konvergencie.
* **Investičný limit:** Celková suma investícií nesmie presiahnuť 10 000 000 EUR.

## 2. Kódovanie riešenia
Riešenie je kódované ako chromozóm pozostávajúci z vektora reálnych čísel o dĺžke $D = 5$.
* **Gény:** Každý gén ($x_1$ až $x_5$) predstavuje konkrétnu sumu investovanú do daného finančného produktu.
* **Rozsah:** Premenné sú zdola ohraničené nulou ($x_i \ge 0$).

## 3. Podrobný popis funkcií a metód pokutovania

### A. Metódy pokutovania (Jadro experimentu)
V kóde sú implementované tri prístupy k riešeniu neprípustných jedincov:
1.  **Mŕtva pokuta (`get_mrtva_pokuta`):** Akékoľvek porušenie ohraničenia priradí jedincovi fixnú vysokú pokutu ($2\ 000\ 000$), čím ho efektívne eliminuje zo selekcie.
2.  **Stupňovitá pokuta (`get_stupnovita_pokuta`):** Pokuta narastá lineárne s počtom porušených ohraničení. Umožňuje algoritmu rozlíšiť mieru neprípustnosti riešenia.
3.  **Úmerná pokuta (`get_umerna_pokuta`):** Pokuta je viazaná na konkrétnu veľkosť porušenia limitov. Poskytuje GA najjemnejšiu informáciu pre navigáciu späť do prípustnej oblasti.

### B. Genetické operátory (OUI Genetic Toolbox)
* **`selbest`**: Zabezpečuje elitárstvo (prenos najlepšieho riešenia bez zmeny).
* **`selsus`**: Stochastické univerzálne vzorkovanie pre diverzifikovaný výber rodičov.
* **`crossov`**: Štandardné kríženie na rekombináciu genetického materiálu.
* **`mutx` / `muta`**: Implementácia aditívnych mutácií na udržanie diverzity a zabránenie uviaznutiu v lokálnom minime.

## 4. Fitness funkcia
Pre potreby minimalizačného algoritmu v Toolboxe je fitness funkcia definovaná ako minimalizácia záporného výnosu s pripočítanou penalizáciou:

$$Fitness = - (0.04x_1 + 0.07x_2 + 0.11x_3 + 0.06x_4 + 0.05x_5) + Pokuta$$

## 5. Experimentálne nastavenia
| Parameter | Hodnota |
| :--- | :--- |
| Veľkosť populácie | 100 jedincov |
| Počet generácií | 200 |
| Počet behov na metódu | 5 (pre overenie stability) |

## 6. Vyhodnotenie ohraničení
Algoritmus v každej generácii striktne monitoruje dodržiavanie nasledujúcich pravidiel:
1.  **Celkový kapitál:** $\sum x_i \le 10\ 000\ 000$
2.  **Limit pre akcie:** $x_1 + x_2 \le 2\ 500\ 000$
3.  **Podmienka konzervatívnosti:** $x_4 \ge x_5$ (Štátne dlhopisy vs. úspory)
4.  **Dlhopisový strop:** $x_3 + x_4 \le 0.5 \cdot \text{celková investícia}$

## 7. Vizualizácia konvergencie

### Porovnanie konvergencie metód
![Všetky behy](img/1.png)

*Graf znázorňuje plynulosť konvergencie pre jednotlivé penalizačné prístupy. Z výsledkov vyplýva, že **úmerná pokuta** vykazuje najvyššiu stabilitu a najrýchlejšiu schopnosť nájsť optimálne riešenie.*
