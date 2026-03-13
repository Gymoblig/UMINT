% Nastavenia GA (spoločné pre všetky metódy podľa bodu 73)
D = 5; 
num = 100;
SPACE_A = [zeros(1,D); ones(1,D)*10000000];
Amp = [ones(1,D)];
max_gen = 500; 

% Názvy metód pre legendu a logiku
metody = {'Bez pokuty', 'Mrtva', 'Stupnovita', 'Umerna'};
vsetky_historie = zeros(length(metody), max_gen);

for m = 1:length(metody)
    fprintf('Beží výpočet pre metódu: %s...\n', metody{m});
    pop = genrpop(num, SPACE_A);
    fitness_history = zeros(1, max_gen);
    
    for gen = 1:max_gen
        fitnesak = zeros(1, num);
        for i = 1:num
            % Základný výnos (fitness bez pokuty) [cite: 46]
            vynos = 0.04*pop(i,1) + 0.07*pop(i,2) + 0.11*pop(i,3) + 0.06*pop(i,4) + 0.05*pop(i,5);
            
            % Výber pokuty podľa aktuálneho cyklu [cite: 64]
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
            
            % Minimalizujeme záporný výnos + pokutu [cite: 63, 126]
            fitnesak(i) = -vynos + pokuta;
        end
        
        % Selekcia a genetika (tvoje overené nastavenie) [cite: 67]
        Best = selbest(pop, fitnesak, 1);
        Rest = selsus(pop, fitnesak, num - 1);
        Incest = crossov(Rest, 1, 0);
        Work = mutx(Incest, 0.05, SPACE_A);   
        AditivnaMutacia = muta(Work, 0.05, Amp, SPACE_A); 
        pop = [Best; AditivnaMutacia];
        
        fitness_history(gen) = min(fitnesak);
    end
    vsetky_historie(m, :) = fitness_history;
end

% --- FINÁLNE VYKRESLENIE (Bod 6 a 89) ---
figure(2); hold on;
farby = {'k-', 'r-', 'g-', 'b-'}; % Čierna prerušovaná pre 'Bez pokuty'
for m = 1:length(metody)
    % Vykresľujeme kladný výnos (otočíme fitness späť) [cite: 127]
    plot(-vsetky_historie(m, :), farby{m}, 'LineWidth', 2);
end

xlabel('Generácia'); 
ylabel('Odhadovaný ročný výnos (EUR)');
title('Porovnanie metód pokutovania na konvergenciu výnosu');
legend(metody, 'Location', 'best');
grid on;


function pen = get_mrtva_pokuta(x)
    % Fixná penalizácia za akékoľvek porušenie 
    if check_any_violation(x), pen = 2000000; else, pen = 0; end
end

function pen = get_stupnovita_pokuta(x)
    % Penalizácia podľa počtu porušených pravidiel 
    v = get_violation_vector(x);
    pen = sum(v > 0) * 100000; 
end

function pen = get_umerna_pokuta(x)
    % Penalizácia podľa miery (veľkosti) porušenia 
    v = get_violation_vector(x);
    pen = sum(v) * 2; 
end

function v = get_violation_vector(x)
    v = zeros(1,4);
    v(1) = max(0, sum(x) - 10000000);             
    v(2) = max(0, (x(1) + x(2)) - 2500000);       
    v(3) = max(0, x(5) - x(4));                   
    v(4) = max(0, (x(3) + x(4)) - 0.5*sum(x));    
end

function is_violating = check_any_violation(x)
    is_violating = any(get_violation_vector(x) > 0);
end