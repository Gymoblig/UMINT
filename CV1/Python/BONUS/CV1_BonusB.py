import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def testfn3c(Pop):
    """
    FEI STU testovacia funkcia.
    Zdroj: https://github.com/STU-FEI-OUI/UMINT-GA/blob/main/Kod/testfn3c.py
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

# --- Nastavenia ---
x_limit = 500
x_range = np.arange(-x_limit, x_limit + 10, 10)
max_starts = 30
max_local_steps = 1000
d_sigma = 5

# 1. Príprava 2D plochy
X, Y = np.meshgrid(x_range, x_range)

# Tu posielame body ako stĺpcové vektory (každý riadok je jeden bod)
Z_x = testfn3c(X.flatten().reshape(-1, 1)).reshape(X.shape)
Z_y = testfn3c(Y.flatten().reshape(-1, 1)).reshape(Y.shape)
Z = Z_x + Z_y

# 2. Vykreslenie 3D povrchu
plt.ion()
fig = plt.figure(figsize=(12, 8), facecolor='w')
ax = fig.add_subplot(111, projection='3d')

surf = ax.plot_surface(X, Y, Z, cmap=cm.jet, alpha=0.4, edgecolor='none')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('F(x,y)')
ax.set_title(f'2D Multi-start: {max_starts} hľadaní')

best_f = np.inf
best_pos = [0, 0]

# 3. Multi-start cyklus
for i in range(1, max_starts + 1):
    # Náhodný štart v 2D rovine
    curr_x = np.random.uniform(-x_limit, x_limit)
    curr_y = np.random.uniform(-x_limit, x_limit)
    curr_f = testfn3c([curr_x])[0] + testfn3c([curr_y])[0]
    
    # Štartovací bod (čierna bodka)
    ax.scatter(curr_x, curr_y, curr_f, color='k', s=25, zorder=5)
    
    # Lokálne hľadanie
    for step in range(max_local_steps):
        new_x = curr_x + d_sigma * np.random.randn()
        new_y = curr_y + d_sigma * np.random.randn()
        
        # Hranice
        new_x = np.clip(new_x, -x_limit, x_limit)
        new_y = np.clip(new_y, -x_limit, x_limit)
        
        new_f = testfn3c([new_x])[0] + testfn3c([new_y])[0]
        
        if new_f < curr_f:
            # Vykreslenie čiary (krok algoritmu)
            ax.plot([curr_x, new_x], [curr_y, new_y], [curr_f, new_f], color='r', linewidth=1.5, alpha=0.8)
            
            curr_x, curr_y, curr_f = new_x, new_y, new_f
            
            # Refresh grafu (voliteľné, spomaľuje výpočet, ale vyzerá to super)
            if step % 10 == 0:
                plt.pause(0.001)

    # Koncový bod (zelený bod)
    ax.scatter(curr_x, curr_y, curr_f, color='g', s=30, edgecolors='white')
    print(f"Hľadanie {i:2d} skončilo na F: {curr_f:.2f}")

    if curr_f < best_f:
        best_f = curr_f
        best_pos = [curr_x, curr_y]

# 4. Absolútny víťaz
ax.scatter(best_pos[0], best_pos[1], best_f, color='r', marker='s', s=150, label='Global Best')
print("-" * 30)
print(f"Absolútne minimum: [x={best_pos[0]:.2f}, y={best_pos[1]:.2f}] s hodnotou F={best_f:.2f}")

plt.ioff()
plt.legend()
plt.show()