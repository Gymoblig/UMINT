# Alokácia investícií do finančných produktov pomocou GA (Zadanie 4)

Tento projekt implementuje genetický algoritmus (GA) v prostredí MATLAB na riešenie úlohy optimálneho rozdelenia investičného kapitálu 10 000 000 EUR. [cite_start]Cieľom je maximalizovať odhadovaný ročný výnos pri dodržaní štyroch kľúčových ohraničení[cite: 3, 42].

## 1. Cieľ úlohy
[cite_start]Navrhnúť a otestovať GA pre výpočet optimálnej alokácie kapitálu do piatich finančných produktov[cite: 37]. 
* [cite_start]**Hlavná úloha:** Porovnať vplyv troch rôznych metód pokutovania (mŕtva, stupňovitá a úmerná) na priebeh konvergencie a stabilitu riešení[cite: 39, 40].
* [cite_start]**Referenčný limit:** Celková investícia nesmie presiahnuť 10 000 000 EUR[cite: 49].

## 2. Kódovanie riešenia
Riešenie je kódované ako vektor reálnych čísel (chromozóm) s dĺžkou $D = 5$.
* [cite_start]**Gény:** Každý gén $x_1$ až $x_5$ predstavuje veľkosť investície v EUR do konkrétneho produktu[cite: 43].
* [cite_start]**Rozsah:** Premenné sú zdola ohraničené nulou ($x_i \ge 0$)[cite: 57].

## 3. Podrobný popis funkcií a metód pokutovania

V kóde sú použité funkcie zabezpečujúce penalizáciu riešení, ktoré porušujú stanovené finančné limity:

### A. Metódy pokutovania (Základ experimentu)
* **`get_mrtva_pokuta`**: Akékoľvek porušenie ohraničenia priradí jedincovi fixnú veľkú pokutu ($2\ 000\ 000$). [cite_start]Tento prístup má neprípustné riešenia "zabiť" v procese selekcie[cite: 142].
* **`get_stupnovita_pokuta`**: Pokuta je definovaná fixnou hodnotou za každý stupeň (počet) porušených ohraničení. [cite_start]Rozlišuje medzi "viac zlým" a "menej zlým" neprípustným riešením[cite: 143, 144].
* **`get_umerna_pokuta`**: Veľkosť pokuty sa viaže na konkrétnu mieru porušenia (vzdialenosť od prípustnej oblasti). [cite_start]Poskytuje algoritmu jemnejšiu informáciu pre navigáciu k legálnym riešeniam[cite: 146, 148].

### B. Genetické operátory (Toolbox)
* [cite_start]**`selbest`**: Elitárna selekcia zabezpečujúca prežitie najlepšieho nájdeného riešenia do ďalšej generácie[cite: 67].
* **`selsus`**: Stochastické univerzálne vzorkovanie použité na výber zvyšnej časti populácie pre reprodukciu.
* **`crossov`**: Kríženie jedincov na výmenu genetickej informácie.
* [cite_start]**`mutx` / `muta`**: Implementácia mutácií na udržanie diverzity a zabránenie uviaznutiu v lokálnom minime[cite: 67].

## 4. Fitness funkcia
[cite_start]Keďže Toolbox pracuje s minimizáciou, fitness funkcia je definovaná ako minimalizácia záporného výnosu s pripočítanou pokutou[cite: 63, 127]:
$$Fitness = - (0.04x_1 + 0.07x_2 + 0.11x_3 + 0.06x_4 + 0.05x_5) + Pokuta$$

## 5. Experimentálne nastavenia
* **Veľkosť populácie:** 100 jedincov
* **Počet generácií:** 200
* [cite_start]**Počet behov:** Každý typ pokutovania bol spustený minimálne 5-krát pre overenie stability[cite: 69].

## 6. Vyhodnotenie ohraničení
[cite_start]Algoritmus stráži dodržiavanie nasledujúcich pravidiel[cite: 47]:
1. [cite_start]**Suma investícií:** $x_1 + x_2 + x_3 + x_4 + x_5 \le 10\ 000\ 000$[cite: 49].
2. [cite_start]**Limit pre akcie:** $x_1 + x_2 \le 2\ 500\ 000$[cite: 51].
3. [cite_start]**Pomer dlhopisov a úspor:** $x_4 \ge x_5$[cite: 53].
4. [cite_start]**Dlhopisový strop:** $x_3 + x_4 \le 0.5 \cdot \text{celková investícia}$[cite: 55].

## 7. Vizualizácia konvergencie

### Porovnanie metód pokutovania
![Všetky behy](img/1.png)

*Graf zobrazuje plynulosť konvergencie jednotlivých metód. Úmerná pokuta spravidla vykazuje najlepšiu stabilitu.*

