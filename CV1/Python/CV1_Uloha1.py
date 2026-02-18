import numpy as np
import matplotlib.pyplot as plt

# 1. Definícia parametrov
x_min = -1000
x_max = 1000

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
    # Vektorizovaný výpočet
    Fit = np.sum(-(d_val) * np.sin(np.sqrt(np.abs(d_val))) + y0, axis=1)

    return Fit

# 2. Vizualizácia funkcie
x_plot = np.linspace(x_min, x_max, 2000)
# Tu posielame pole (2D), funkcia vráti pole výsledkov
y_plot = testfn3c(x_plot.reshape(-1, 1))

plt.figure(figsize=(10, 6))
plt.plot(x_plot, y_plot, 'b-', linewidth=1.5, label='Priebeh funkcie (testfn3c)')
plt.grid(True, linestyle=':', alpha=0.7)
plt.title('Inicializácia a vizualizácia funkcie Schwefel (FEI STU verzia)')
plt.xlabel('x')
plt.ylabel('F(x)')

# 3. Inicializácia: Náhodne vygenerovaný bod x0
x0 = np.random.uniform(x_min, x_max)

# OPRAVA: Posielame [x0], aby to bolo 1D pole a funkcia nepadla na IndexError
y0 = testfn3c([x0])[0]

# 4. Vykreslenie počiatočného bodu
plt.plot(x0, y0, 'ro', markersize=10, markerfacecolor='r', label='Počiatočný bod x0')
plt.legend()

print(f"Štartovací bod x0: {x0:.2f}")
print(f"Hodnota funkcie v x0: {y0:.2f}")

plt.show()