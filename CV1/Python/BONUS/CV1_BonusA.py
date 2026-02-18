import numpy as np
import matplotlib.pyplot as plt

def testfn3c(Pop):
    """
    MATLAB/Python interpretácia zo zdroja: 
    https://github.com/STU-FEI-OUI/UMINT-GA/blob/main/Kod/testfn3c.py
    """
    Pop = np.asarray(Pop, dtype=float)
    if Pop.ndim == 1:
        lpop, lstring = 1, Pop.shape[0]
        X = Pop.reshape(1, lstring)
    else:
        lpop = Pop.shape[0]
        lstring = int(np.prod(Pop.shape[1:]))
        X = Pop.reshape(lpop, lstring)

    x0, y0 = 30.0, 100.0
    d_val = X - x0
    Fit = np.sum(-(d_val) * np.sin(np.sqrt(np.abs(d_val))) + y0, axis=1)
    return Fit

def stochastic_hill_climbing(x_curr, f_curr, d, max_local_iters, ax):
    """
    Stochastické lokálne hľadanie pomocou náhodného šumu (Gaussovo rozdelenie).
    """
    for j in range(max_local_iters):
        # Generujeme kandidáta: aktuálna pozícia + náhodný šum (randn)
        x_candidate = x_curr + d * np.random.randn()
        
        # Ošetrenie hraníc
        x_candidate = np.clip(x_candidate, -1000, 1000)
        
        # Výpočet fitness pre kandidáta (posielame ako list kvôli testfn3c)
        f_candidate = testfn3c([x_candidate])[0]
        
        # Ak je kandidát lepší, presunieme sa tam
        if f_candidate < f_curr:
            x_curr = x_candidate
            f_curr = f_candidate
            
            # Vykreslenie kroku (modrá bodka)
            ax.plot(x_curr, f_curr, 'b.', markersize=5, alpha=0.6)
            plt.pause(0.001) # Animácia "kráčania"
            
    # Konečný bod lokálneho hľadania (zelený)
    ax.plot(x_curr, f_curr, 'go', markerfacecolor='g', markersize=6)
    return x_curr, f_curr

# --- Nastavenia ---
x_min, x_max = -1000, 1000
max_iter = 30           # Počet náhodných reštartov
d_sigma = 10            # Smerodajná odchýlka pre skok
max_local_steps = 100   # Pokusy v každej iterácii

# 1. Príprava grafu
plt.ion()
fig, ax = plt.subplots(figsize=(12, 7))

x_plot = np.linspace(x_min, x_max, 1000)
y_plot = testfn3c(x_plot.reshape(-1, 1))

ax.plot(x_plot, y_plot, 'r', linewidth=1, alpha=0.3, label='F(x)')
ax.grid(True, linestyle=':', alpha=0.6)
ax.set_title(f'Stochastický Multi-start Hill Climbing ({max_iter} pokusov)')

bestmin = np.inf
xmin = None

# 2. Multi-start cyklus
for i in range(1, max_iter + 1):
    # Náhodný štartovací bod
    x_current = np.random.uniform(x_min, x_max)
    f_current = testfn3c([x_current])[0]
    
    # Vykreslenie štartu (čierny bod)
    ax.plot(x_current, f_current, 'ko', markersize=4)
    
    # Volanie stochastického hľadania
    x_min_found, f_min_found = stochastic_hill_climbing(x_current, f_current, d_sigma, max_local_steps, ax)
    
    print(f"Iterácia {i:2d} ukončená: x={x_min_found:8.2f}, F(x)={f_min_found:10.4f}")
    
    # Kontrola najlepšieho globálneho riešenia
    if f_min_found < bestmin:
        bestmin = f_min_found
        xmin = x_min_found

# 3. Záverečné vyhodnotenie
print("\n" + "="*45)
print(f"Najmenšie nájdené minimum (Global): \nx = {xmin:.4f} \nF(x) = {bestmin:.4f}")
print("="*45)

# Zvýraznenie absolútne najlepšieho bodu
ax.plot(xmin, bestmin, 'rs', markersize=12, fillstyle='none', markeredgewidth=3, label='Best Global')
ax.legend()

plt.ioff()
plt.show()