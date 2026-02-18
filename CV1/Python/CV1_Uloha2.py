import numpy as np
import matplotlib.pyplot as plt

def testfn3c(Pop):
    """
    MATLAB/Python interpretácia:
    Výpočet fitness pre ľubovoľný rozmer vstupu Pop.
    SOURCE: https://github.com/STU-FEI-OUI/UMINT-GA/blob/main/Kod/testfn3c.py
    """
    Pop = np.asarray(Pop, dtype=float)

    if Pop.ndim == 1:
        lpop = 1
        lstring = Pop.shape[0]
        X = Pop.reshape(1, lstring)
    else:
        lpop = Pop.shape[0]
        lstring = int(np.prod(Pop.shape[1:]))
        X = Pop.reshape(lpop, lstring)

    x0 = 30.0
    y0 = 100.0
    d_val = X - x0
    # Vektorizovaný výpočet sumy pre každého jedinca (riadok)
    Fit = np.sum(-(d_val) * np.sin(np.sqrt(np.abs(d_val))) + y0, axis=1)

    return Fit

# --- Nastavenia ---
x_min, x_max = -1000, 1000
max_iter = 30
d_step = 10

# 1. Príprava prostredia a vizualizácia pozadia
plt.ion() # Interaktívny režim pre animáciu
fig, ax = plt.subplots(figsize=(12, 7))

x_plot = np.linspace(x_min, x_max, 1000)
# Tu posielame celé pole naraz (2D tvar), vráti pole výsledkov
y_plot = testfn3c(x_plot.reshape(-1, 1)) 

ax.plot(x_plot, y_plot, 'r', linewidth=1, alpha=0.4, label='F(x)')
ax.grid(True, linestyle=':', alpha=0.6)
ax.set_title(f'Multi-start Hill Climbing (N={max_iter}) - testfn3c')

best_min_global = np.inf
x_min_global = None

# 2. Multi-start cyklus
for i in range(1, max_iter + 1):
    x_curr_val = np.random.uniform(x_min, x_max)
    
    # OPRAVA: Posielame [x_curr_val], aby to bolo 1D pole a funkcia nepadla
    f_curr = testfn3c([x_curr_val])[0] 
    
    # Štartovací bod (čierny krúžok)
    ax.plot(x_curr_val, f_curr, 'ko', markersize=5)
    
    while True:
        x_left = x_curr_val - d_step
        x_right = x_curr_val + d_step

        # Hranice a výpočet fitness pre susedov (opäť balíme do listu [])
        f_l = testfn3c([x_left])[0] if x_left >= x_min else np.inf
        f_r = testfn3c([x_right])[0] if x_right <= x_max else np.inf

        vals = [f_curr, f_r, f_l]
        idx = np.argmin(vals)

        if idx == 1: # Smer doprava
            x_curr_val, f_curr = x_right, f_r
        elif idx == 2: # Smer doľava
            x_curr_val, f_curr = x_left, f_l
        else:
            # Lokálne minimum nájdené (zelený bod)
            ax.plot(x_curr_val, f_curr, 'go', markersize=4)
            break
        
        # Vizuálna stopa hľadania
        ax.plot(x_curr_val, f_curr, 'b.', markersize=2, alpha=0.3)
        plt.pause(0.005)

    if f_curr < best_min_global:
        best_min_global = f_curr
        x_min_global = x_curr_val
    
    print(f"Iterácia {i:2d}: Koniec v x = {x_curr_val:8.2f}")

# 3. Finálne vyhodnotenie
print("\n" + "="*45)
print(f"GLOBÁLNE MINIMUM: x = {x_min_global:.4f}, F(x) = {best_min_global:.4f}")
print("="*45)

ax.plot(x_min_global, best_min_global, 'rs', markersize=12, fillstyle='none', 
        markeredgewidth=2, label='Global Best')
ax.legend()
plt.ioff() 
plt.show()