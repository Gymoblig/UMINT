# Optimalizácia problému obchodného cestujúceho (TSP) pomocou GA

Tento projekt implementuje genetický algoritmus (GA) v prostredí MATLAB na riešenie problému obchodného cestujúceho pre 25 statických bodov. Cieľom je nájsť najkratšiu možnú trajektóriu so začiatkom v bode 1 a koncom v bode 25.

## 1. Cieľ úlohy
Cieľom bolo navrhnúť GA pre výpočet najkratšej dráhy robota, ktorý začína v bode $[0,0]$, navštívi všetky definované body a vráti sa späť do bodu $[0,0]$.
* **Referenčná kontrolná hodnota:** 468.1095
* **Dosiahnutá hodnota:** **468.11**

## 2. Kódovanie riešenia
Riešenie je kódované ako chromozóm pozostávajúci z **indexov bodov** (nie súradníc). 
* **Fixné body:** Prvý gén (index 1) a posledný gén (index 25) sú fixne nastavené na bod $[0,0]$.
* **Permutačné jadro:** Algoritmus optimalizuje poradie vnútornej sekvencie bodov, t.j. **indexy 2 až 24**.

## 3. Genetické operátory a zdôvodnenie zmien
V porovnaní s predchádzajúcimi úlohami (napr. Schwefelova funkcia), kde boli použité operátory `crossov` a `muta`, bolo v tejto úlohe nutné použiť špecializované permutačné operátory.

> **Zdôvodnenie:** Štandardné operátory spojitej optimalizácie by v prípade indexov miest viedli k vzniku neplatných ciest (duplicity miest alebo ich vynechanie). Aditívna mutácia by navyše vytvorila neexistujúce indexy (neceločíselné hodnoty).

**Použité Toolbox operátory:**
* **Kríženie:** `crosord` (Order crossover) – zabezpečuje legálnu permutáciu bez opakovania prvkov.
* **Mutácia:** Kombinácia `swappart` (výmena pozícií), `invord` (inverzia úseku) a `swapgen` (lokálna regenerácia). Operácie sú striktne obmedzené na rozsah génov 2-24.

## 4. Fitness funkcia
Fitness funkcia je definovaná ako **celková dĺžka dráhy**. Výpočet prebieha ako suma euklidovských vzdialeností medzi susednými bodmi v poradí, v akom sú zapísané v chromozóme.

## 5. Experimentálne nastavenia
Algoritmus bol testovaný s nasledujúcimi parametrami:
* **Veľkosť populácie:** 200 jedincov
* **Počet generácií:** 1500
* **Selekcia:** Elitizmus (`selbest`) v kombinácii s turnajovou selekciou (`seltourn`).

## 6. Vyhodnotenie 10 behov
Algoritmus bol spustený 10-krát pre overenie stability a úspešnosti.

```text
┌──────────────────────────────────────────────────┐
│     SYSTÉM PRE GENETICKÚ OPTIMALIZÁCIU TRASY     │
├──────────────────────────────────────────────────┤
│ Nastavenia:  10 behov | 1500 generácií | Pop: 200│
├───────────┬──────────────────┬───────────────────┤
│  ID Behu  │   Stav Procesu   │ Najlepšia Fitness │
├───────────┼──────────────────┼───────────────────┤
│    01     │    Spracúvam...  │        472.58     │
│    02     │    Spracúvam...  │        472.58     │
│    03     │    Spracúvam...  │        476.67     │
│    04     │    Spracúvam...  │        468.11     │
│    05     │    Spracúvam...  │        472.58     │
│    06     │    Spracúvam...  │        468.11     │
│    07     │    Spracúvam...  │        468.11     │
│    08     │    Spracúvam...  │        507.79     │
│    09     │    Spracúvam...  │        472.58     │
│    10     │    Spracúvam...  │        472.58     │
├───────────┴──────────────────┴───────────────────┤
│         FINÁLNE ŠTATISTICKÉ VYHODNOTENIE         │
├──────────────────────────────────────┬───────────┤
│ Absolútne globálne minimum           │    468.11 │
│ Priemerná hodnota fitness            │    475.17 │
│ Celková úspešnosť riešení (pod 480)  │      90 % │
└──────────────────────────────────────┴───────────┘
```
**Štatistický záver:** 90 % behov dosiahlo hodnotu $\leq 480$, čím bola podmienka úspešnosti (min. 50 %) bohato splnená.

## 7. Finálne výsledky a vizualizácia

### Priebeh fitness (Konvergencia)
*Graf zobrazuje vývoj fitness pre všetkých 10 behov a ich priemernú krivku.*


### Najlepšia nájdená dráha (Fitness: 468.11)
![Najlepšia nájdená dráha](img/1.png)
*Vykreslenie optimálnej trajektórie robota. Štart a cieľ sú v bode [0,0].*

### Najlepší nájdený genóm
Genóm pre hodnotu 468.11 zodpovedá poradiu bodov na obrázku (začína v $[0,0]$, pokračuje cez bod s dĺžkou úseku 15.1, končí návratom z bodu s úsekom 49.0).
