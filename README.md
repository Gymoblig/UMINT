# UMINT - Umela inteligencia

Tento repozitar sluzi na evidenciu a spravu rieseni zadani z predmetu Umela inteligencia (UMINT). Projekt je strukturovany podla jednotlivych cviceni a obsahuje porovnania implementacii v jazykoch MATLAB a Python.

## Struktura projektu

 Projekt je rozdeleny na hlavne casti: implementacie uloh (CV), zdielane kniznice (libs) a podklady k prednaskam.

### Cvicenia
* **[CV1](./CV1)**: Optimalizacia a Hill Climbing (Schwefelova funkcia).
    * [Matlab](./CV1/Matlab): Implementacie v prostredi MATLAB.
    * [Python](./CV1/Python): Portovane riesenia v jazyku Python.
* **CV2**: (Pripravuje sa)
* **CV3**: (Pripravuje sa)

### Kniznice a nastroje
* **[libs/Genetic-toolbox](./libs/Genetic-toolbox)**: Nastroje pre pracu s genetickymi algoritmami.
* **[libs/UMINT-GA](./libs/UMINT-GA)**: Specificke kniznice pre evolucne vypocty a testovacie funkcie.

## Prehlad riesenych uloh

### CV1: Lokalna optimalizacia
Zamerane na hladanie extremov ucelovych funkcii v 1D a 2D priestore.
- Vizualizacia Schwefelovej funkcie (testfn3c).
- Hill Climbing (deterministicky s fixnym krokom).
- Stochasticky Hill Climbing (vyuzitie Gaussovho sumu).
- Multi-start strategia pre najdenie globalneho minima.

## Technicke poziadavky

### MATLAB
- Vyziadane zakladne toolboxy pre optimalizaciu a vizualizaciu (Optimization Toolbox).

### Python
- Verzia 3.8 a vyssia.
- Kniznice: `numpy`, `matplotlib`

Instalacia potrebnych Python balikov:
```bash
pip install numpy matplotlib
