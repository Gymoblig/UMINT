# Optimalizácia problému obchodného cestujúceho (TSP) pomocou GA

Tento projekt implementuje genetický algoritmus (GA) v prostredí MATLAB na riešenie problému obchodného cestujúceho pre 25 statických bodov. Cieľom je nájsť najkratšiu možnú trajektóriu so začiatkom v bode 1 a koncom v bode 25.

## Štruktúra projektu

* **CV3.m** – Hlavný vykonávací skript. Obsahuje definíciu súradníc miest (matica `B`), nastavenie evolučných parametrov, logiku genetických operátorov (selekcia, kríženie, mutácia) a generovanie finálneho grafického výstupu.

## Popis algoritmu

### 1. Inicializácia populácie
Proces začína vytvorením počiatočnej populácie náhodných permutácií. Algoritmus striktne fixuje prvý stĺpec na hodnotu 1 a posledný stĺpec na hodnotu 25. Vnútorná sekvencia miest (indexy 2 až 24) je generovaná náhodne, čím je zabezpečená rôznorodosť riešení pri zachovaní fixných koncových bodov.

### 2. Výpočet zdatnosti (Fitness)
Zdatnosť každého jedinca je definovaná ako celková dĺžka trasy. Výpočet prebieha kumulatívnym sčítaním euklidovských vzdialeností medzi po sebe idúcimi uzlami trasy na základe ich priestorových súradníc.



### 3. Evolučný cyklus
Optimalizácia je postavená na iteratívnom zlepšovaní populácie v dvoch úrovniach:

* **Riadiaci cyklus behov (`nRuns`):** Vykonáva 10 nezávislých pokusov pre elimináciu vplyvu náhody a získanie globálneho minima.
* **Generačný cyklus (`nGen`):** V každej z 1500 generácií prebieha transformácia populácie:
    * **Selekcia a Elitizmus:** Najlepší jedinci sú identifikovaní pomocou `selbest` a prenášaní do ďalšej generácie pre zachovanie kvality riešenia.
    * **Variácia:** Ostatní jedinci prechádzajú turnajovou selekciou (`seltourn`) a následným krížením typu `crosord`.
    * **Mutácia:** Na zabezpečenie prieskumu stavového priestoru sa aplikuje trojica mutácií: výmena (`swappart`), inverzia (`invord`) a regenerácia (`swapgen`). Operácie sú obmedzené na rozsah `2:numPoints-1`, aby nedošlo k porušeniu fixných bodov.

## Výsledky optimalizácie

Výstup z konzoly potvrdzujúci dosiahnutie globálneho minima 468.11:

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
## Grafická analýza výsledkov

Vizualizácia predstavuje najlepšiu nájdenú trasu s celkovou dĺžkou 468.11. Grafické prostredie je nakonfigurované na pevný rozsah osí 100x100 jednotiek, pričom zobrazenie využíva nasledujúcu logiku vrstvenia a prvkov:

* **Trajektória:** Optimálna cesta je vykreslená ako čierna línia (`'k-'`) s hrúbkou 2.2, ktorá tvorí základnú vrstvu grafu.
* **Uzly (Mestá):** Body reprezentujúce mestá sú vykreslené farbou magenta (`'m'`) a sú umiestnené na najvyššej vrstve, aby prekrývali čiernu líniu trasy.
* **Anotácie vzdialeností:** Každý segment trasy obsahuje číselný údaj o svojej dĺžke, ktorý je umiestnený v strede úsečky v bielom textovom poli pre maximálnu čitateľnosť.
* **Špeciálne body:** Počiatočný bod (1) je zvýraznený zeleným štvorcom a koncový bod (25) červeným štvorcom.
* **Mierka osí:** Osi X a Y sú pevne nastavené na rozsah [0, 100] s krokom 10 jednotiek, čo zabezpečuje, že hodnota 100 je posledným číslom na oboch osiach.

![Grafické znázornenie najlepšieho riešenia](img/1.png)

### Legenda a štatistika behov
Súčasťou grafického výstupu je rozšírená legenda umiestnená mimo hlavnej plochy grafu. Obsahuje:
1. Identifikáciu objektov (trasa, uzly, štart, cieľ).
2. Podrobný log všetkých 10 vykonaných behov s ich konkrétnymi výslednými hodnotami fitness, čo umožňuje rýchlu vizuálnu kontrolu stability algoritmu.