def testfn3c(Pop):
    """
    MATLAB/Python:
        - lpop    = počet jedincov (rozmer 1)
        - lstring = počet génov na jedinca (rozmer 2),
                   pričom ak má Pop viac než 2 dimenzie, lstring je
                   súčin rozmerov.

    Fitness výpočet:
        Pre každého jedinca i:
            Fit(i) = sum_{j=1..lstring} ( -(x_ij - x0) * sin( sqrt(abs(x_ij - x0)) ) + y0 )
        kde x0 = 30, y0 = 100.

    Vstup:
        Pop:
            - 2D: tvar (lpop, lstring)
            - 1D: tvar (lstring,) -> interpretuje sa ako 1 jedinec (lpop=1)
            - ND (>=3D): tvar (lpop, d2, d3, ...) -> lstring = d2*d3*...
              a interne sa pre výpočet sploští na (lpop, lstring), aby zodpovedal MATLAB interpretácii.

    Výstup:
        - 1D NumPy pole tvaru (lpop,), t. j. fitness pre každého jedinca.
    """
    import numpy as np

    Pop = np.asarray(Pop, dtype=float)

    if Pop.ndim == 1:
        # MATLAB: size(1xN) -> lpop=1, lstring=N
        lpop = 1
        lstring = Pop.shape[0]
        X = Pop.reshape(1, lstring)
    else:
        # MATLAB: [m,n]=size(A) pri ND -> n = prod(size(A,2:end))
        lpop = Pop.shape[0]
        lstring = int(np.prod(Pop.shape[1:]))
        X = Pop.reshape(lpop, lstring)

    # --- Výpočet fitness ---
    x0 = 30.0
    y0 = 100.0
    d = X - x0
    Fit = np.sum(-(d) * np.sin(np.sqrt(np.abs(d))) + y0, axis=1)

    return Fit
