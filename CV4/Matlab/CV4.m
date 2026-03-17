%% ZADANIE Č. 4: ALOKÁCIA INVESTÍCIÍ DO FINANČNÝCH PRODUKTOV

% --- KONFIGURÁCIA EXPERIMENTU (Bod 1 a 4 zadania) ---
D = 5;              % Počet produktov
num = 100;          % Veľkosť populácie
max_gen = 200;      
pocet_behov = 5;    % Bod 4: Opakovanie výpočtu minimálne 5-krát

SPACE_A = [zeros(1,D); ones(1,D)*10000000];
Amp = [ones(1,D)];  

% Definícia metód pokutovania (Bod 3 zadania)
metody = {'Bez pokuty', 'Mrtva', 'Stupnovita', 'Umerna'};
vsetky_historie = zeros(length(metody), max_gen);

for m = 1:length(metody)
    fprintf('Spracovávam metódu: %s...\n', metody{m});
    
    % --- GRAFICKÉ ZOBRAZENIE BEHOV (Bod 4 zadania) ---
    figure(m); hold on;
    title(['Stabilita konvergencie: ', metody{m}]);
    xlabel('Generácia'); ylabel('Fitness');
    
    najlepsia_fitness_metody = inf;
    najlepsi_x_metody = zeros(1, D);
    
    for b = 1:pocet_behov
        pop = genrpop(num, SPACE_A);
        fitness_history = zeros(1, max_gen);
        
        for gen = 1:max_gen
            fitnesak = zeros(1, num);
            for i = 1:num
                % Výpočet výnosu (Bod 4 zadania)
                vynos = 0.04*pop(i,1) + 0.07*pop(i,2) + 0.11*pop(i,3) + 0.06*pop(i,4) + 0.05*pop(i,5);
                
                % Implementácia rôznych metód pokutovania (Bod 3 zadania)
                switch metody{m}
                    case 'Bez pokuty'
                        pokuta = 0;
                    case 'Mrtva'
                        pokuta = get_mrtva_pokuta(pop(i,:));
                    case 'Stupnovita'
                        pokuta = get_stupnovita_pokuta(pop(i,:));
                    case 'Umerna'
                        pokuta = get_umerna_pokuta(pop(i,:));
                end
                
                % Fitness funkcia pre GA Toolbox (Bod 2 a 4 zadania)
                fitnesak(i) = -vynos + pokuta;
            end
            
            % Genetické operátory (Selekcia, kríženie, mutácia)
            Best = selbest(pop, fitnesak, 1);
            Rest = selsus(pop, fitnesak, num - 1);
            Work = mutx(crossov(Rest, 1, 0), 0.05, SPACE_A);   
            pop = [Best; muta(Work, 0.05, Amp, SPACE_A)];
            
            fitness_history(gen) = min(fitnesak);
        end
        
        % Vykreslenie všetkých 5 behov (Bod 4 zadania)
        plot(fitness_history, 'DisplayName', sprintf('Beh %d', b));
        
        % Identifikácia a uloženie najlepšieho riešenia (Bod 5 zadania)
        if fitness_history(end) < najlepsia_fitness_metody
            najlepsia_fitness_metody = fitness_history(end);
            vsetky_historie(m, :) = fitness_history;
            najlepsi_x_metody = pop(1,:);
        end
    end
    legend('show'); grid on;
    
    % --- ARCHIVÁCIA VÝSLEDKOV PRE PREZENTÁCIU (Bod 5 a 7 zadania) ---
    fprintf('>>> FINÁLNE DÁTA PRE METÓDU: %s\n', metody{m});
    fprintf('Optimálna alokácia x: [%.0f, %.0f, %.0f, %.0f, %.0f] EUR\n', najlepsi_x_metody);
    v_final = get_violation_vector(najlepsi_x_metody);
    fprintf('Kontrola ohraničení (v): [%.2f, %.2f, %.2f, %.2f]\n\n', v_final);
end

% --- POROVNANIE METÓD POKUTOVANIA (Bod 6 zadania) ---
figure(5); hold on;
farby = {'k--', 'r-', 'g-', 'b-'}; 
for m = 1:length(metody)
    % Zobrazenie priebehov konvergencie pre archiváciu (Bod 6 a 7 zadania)
    plot(-vsetky_historie(m, :), farby{m}, 'LineWidth', 2);
end
xlabel('Generácia'); ylabel('Ročný výnos (EUR)');
title('Porovnanie metód pokutovania');
legend(metody, 'Location', 'best');
grid on;

%% FUNKCIE OHRANIČENÍ A POKÚT (Bod 3 a 4 zadania)

function pen = get_mrtva_pokuta(x)
    if any(get_violation_vector(x) > 0), pen = 2000000; else, pen = 0; end
end

function pen = get_stupnovita_pokuta(x)
    v = get_violation_vector(x);
    pen = sum(v > 0) * 100000; 
end

function pen = get_umerna_pokuta(x)
    v = get_violation_vector(x);
    pen = sum(v) * 2; 
end

function v = get_violation_vector(x)
    % Výpočet miery porušenia štyroch ohraničení (Bod 4 zadania)
    v = zeros(1,4);
    v(1) = max(0, sum(x) - 10000000);             
    v(2) = max(0, (x(1) + x(2)) - 2500000);       
    v(3) = max(0, x(5) - x(4));                   
    v(4) = max(0, (x(3) + x(4)) - 0.5*sum(x));    
end