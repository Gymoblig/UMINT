%% ZADANIE Č. 4: ALOKÁCIA INVESTÍCIÍ DO FINANČNÝCH PRODUKTOV
% Optimalizácia portfólia pomocou Genetického Algoritmu (GA)

% --- KONFIGURÁCIA ---
D = 5;              % Počet produktov (x1 až x5)
num = 100;          % Populácia (počet jedincov v jednej generácii)
max_gen = 400;      % Počet generácií (koľkokrát sa populácia vyvinie)
pocet_behov = 5;    % Stabilita: algoritmus pustíme 5-krát pre každú metódu

% Priestor riešení (Body 0 až 10 miliónov)
SPACE_A = [zeros(1,D); ones(1,D)*10000000]; 

% Amp: Krok mutácie (ako ďaleko od pôvodnej hodnoty môže "skočiť" nový jedinec)
Amp = [ones(1,D) * 100000]; 

metody = {'Mrtva', 'Stupnovita', 'Umerna'};
vsetky_historie = zeros(length(metody), max_gen);

for m = 1:length(metody)
    fprintf('--- Spracovávam metódu: %s ---\n', metody{m});
    
    % Príprava grafu pre stabilitu behov (Figure 1, 2, 3)
    figure(m); clf; hold on;
    title(['Stabilita konvergencie (všetky behy): ', metody{m}]);
    xlabel('Generácia'); ylabel('Ročný výnos (EUR)');
    
    najlepsia_fitness_metody = inf;
    najlepsi_x_metody = zeros(1, D);
    
    for b = 1:pocet_behov
        pop = genrpop(num, SPACE_A); % Inicializácia náhodnej populácie
        vynos_history = zeros(1, max_gen); 
        
        for gen = 1:max_gen
            fitnesak = zeros(1, num);
            ciste_vynosy = zeros(1, num);
            
            for i = 1:num
                x = pop(i,:);
                % Výpočet čistého ročného výnosu (Fitness cieľ)
                vynos = 0.04*x(1) + 0.07*x(2) + 0.11*x(3) + 0.06*x(4) + 0.05*x(5);
                ciste_vynosy(i) = vynos;
                
                % VÝBER METÓDY POKUTOVANIA
                switch metody{m}
                    case 'Mrtva'
                        v = get_violation_vector(x);
                        if any(v > 0)
                            pokuta = 1e12 + sum(v)*10; 
                        else
                            pokuta = 0;
                        end
                    case 'Stupnovita'
                        pokuta = get_stupnovita_pokuta(x);
                    case 'Umerna'
                        pokuta = get_umerna_pokuta(x);
                end
                
                % Fitness funkcia: Minimalizujeme (-vynos + pokuta)
                % Záporný výnos znamená, že hľadáme najmenšie záporné číslo = najväčší zisk
                fitnesak(i) = - vynos + pokuta;
            end
            
            % Selekcia a záznam najlepšieho riešenia v generácii
            [best_val, idx] = min(fitnesak);
            
            % Ak je najlepší jedinec stále "pokutovaný" (best_val > 0), v grafe vidíme 0
            if best_val > 0
                vynos_history(gen) = 0; 
            else
                vynos_history(gen) = ciste_vynosy(idx);
            end
            
            % GA OPERÁTORY
            Best = selbest(pop, fitnesak, 1);           % Elitizmus (najlepší prežíva)
            Rest = selsus(pop, fitnesak, num - 1);     % Selekcia (výber rodičov)
            Work = mutx(crossov(Rest, 1, 0), 0.1, SPACE_A); % Kríženie
            pop = [Best; muta(Work, 0.1, Amp, SPACE_A)];    % Mutácia (náhodná zmena)
        end
        
        plot(vynos_history, 'DisplayName', sprintf('Beh %d', b));
        
        % Uloženie absolútne najlepšieho riešenia pre túto metódu
        if min(fitnesak) < najlepsia_fitness_metody
            najlepsia_fitness_metody = min(fitnesak);
            vsetky_historie(m, :) = vynos_history;
            najlepsi_x_metody = pop(1,:);
        end
    end
    ylim([0, 1.2e6]); legend('show'); grid on;
    
    % --- DETAILNÝ VÝPIS DO KONZOLY ---
    fprintf('  Najlepšia alokácia (Optimálne x):\n');
    fprintf('    x1 (Bežné akcie):     %10.2f EUR\n', najlepsi_x_metody(1));
    fprintf('    x2 (Preferenčné akcie):%10.2f EUR\n', najlepsi_x_metody(2));
    fprintf('    x3 (Podnikové dlhopisy):%10.2f EUR\n', najlepsi_x_metody(3));
    fprintf('    x4 (Štátne dlhopisy):   %10.2f EUR\n', najlepsi_x_metody(4));
    fprintf('    x5 (Úspory v banke):    %10.2f EUR\n', najlepsi_x_metody(5));
    fprintf('  Celkový ročný výnos: %.2f EUR\n\n', -najlepsia_fitness_metody);
end

% --- POROVNANIE VŠETKÝCH METÓD (Figure 4) ---
figure(4); clf; hold on;
farby = {'r-', 'g-', 'b-'}; 
for m = 1:length(metody)
    plot(vsetky_historie(m, :), farby{m}, 'LineWidth', 2);
end
xlabel('Generácia'); ylabel('Ročný výnos (EUR)');
title('Porovnanie metód pokutovania (Najlepšie behy)');
legend(metody, 'Location', 'best');
ylim([0, 1.2e6]); grid on;

%% --- POMOCNÉ FUNKCIE ---

function pen = get_stupnovita_pokuta(x)
    % Trestá za počet porušených podmienok, nie za veľkosť chyby
    v = get_violation_vector(x);
    pen = sum(v > 0) * 5e6; % 5 miliónov za každú jednu porušenú podmienku
end

function pen = get_umerna_pokuta(x)
    % Trestá priamo úmerne tomu, o koľko bol limit prekročený
    v = get_violation_vector(x);
    pen = sum(v) * 5; % Koeficient prísnosti (váha)
end

function v = get_violation_vector(x)
    % Funkcia max(0, hodnota - limit) vráti:
    % - 0, ak je hodnota pod limitom (podmienka splnená)
    % - rozdiel, ak je hodnota nad limitom (veľkosť porušenia)
    
    v = zeros(1,5);
    v(1) = max(0, sum(x) - 10000000);             % Limit: Celkovo 10M
    v(2) = max(0, (x(1) + x(2)) - 2500000);       % Limit: Akcie max 2.5M
    v(3) = max(0, x(5) - x(4));                   % Limit: Štátne dlhopisy >= Úspory
    v(4) = max(0, (x(3) + x(4)) - 0.5*sum(x));    % Limit: Dlhopisy max 50% celku
    v(5) = sum(max(0, -x));                       % Limit: Nezápornosť (x >= 0)
end