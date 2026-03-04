%% OPTIMALIZÁCIA TRASY PROBLÉMU OBCHODNÉHO CESTUJÚCEHO (TSP)
% Implementácia genetického algoritmu s profesionálnym ASCII reportom.
% Vizualizácia: Čierna trasa, Magenta mestá navrchu.

clear; clc; close all;

% --- Definícia súradníc miest ---
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

% --- Evolučné parametre ---
nRuns = 10;                % Počet behov podľa cviko3.m
nGen = 1500;               % Počet generácií
popSize = 200;             % Veľkosť populácie
numPoints = size(B, 1);    % Počet miest (25)
limit = 480;               % Limit úspešnosti

% --- Inicializácia globálnych premenných ---
globalBestFit = inf;
globalBestPath = [];
runResults = zeros(nRuns, 1);

% --- Profesionálny Tabuľkový Úvod (ASCII Art) ---
fprintf('┌──────────────────────────────────────────────────┐\n');
fprintf('│     SYSTÉM PRE GENETICKÚ OPTIMALIZÁCIU TRASY     │\n');
fprintf('├──────────────────────────────────────────────────┤\n');
fprintf('│ Nastavenia: %3d behov | %4d generácií | Pop: %3d│\n', nRuns, nGen, popSize);
fprintf('├───────────┬──────────────────┬───────────────────┤\n');
fprintf('│  ID Behu  │   Stav Procesu   │ Najlepšia Fitness │\n');
fprintf('├───────────┼──────────────────┼───────────────────┤\n');

%% HLAVNÝ VÝPOČTOVÝ CYKLUS
for r = 1:nRuns
    % 1. Inicializácia populácie [Logika: genPermPop.m - Start=1, End=25]
    Chrom = genPermPop(popSize, numPoints); 
    runBestFit = inf;
    
    % Dynamický update riadku v konzole
    fprintf('│    %02d     │    Spracúvam...  │', r);
    
    for gen = 1:nGen
        % 2. Fitness evaluácia [Logika: Fitness.m - Euklidovská vzdialenosť]
        % Poznámka: Tvoja funkcia Fitness vracia riadkový vektor, transponujeme ho
        ObjV = Fitness(Chrom, B)'; 
        
        % Sledovanie elity v aktuálnom behu
        [minVal, minIdx] = min(ObjV);
        if minVal < runBestFit
            runBestFit = minVal;
            runBestPath = Chrom(minIdx, :);
        end
        
        % 3. Selekcia [Logika: cviko3.m]
        best = selbest(Chrom, ObjV, [2 2 2]); 
        supbest = selbest(Chrom, ObjV, 10);
        supbest2 = seltourn(Chrom, ObjV, popSize - 16); 
        
        % 4. Kríženie a Mutácia [Logika: cviko3.m]
        mix = crosord([supbest; supbest2], 1);
        mutRange = 2:numPoints-1; % Ochrana fixných bodov 1 a 25
        
        % Aplikácia mutácií na povolený rozsah
        mut = swappart(mix(:, mutRange), 0.1); 
        mut = invord(mut, 0.4); 
        mut = swapgen(mut, 0.1); 
        
        % Návrat mutovaných častí do matice mix
        mix(:, mutRange) = mut;
        
        % 5. Reinsercia s uchovaním elity
        Chrom = [best; mix];
        Chrom(1, :) = runBestPath; 
    end
    
    runResults(r) = runBestFit;
    
    % Aktualizácia absolútne najlepšieho výsledku
    if runBestFit < globalBestFit
        globalBestFit = runBestFit;
        globalBestPath = runBestPath;
    end
    
    % Uzatvorenie riadku v tabuľke
    fprintf('      %8.2f     │\n', runBestFit);
end

% --- Záverečný ASCII Report ---
successRate = (sum(runResults < limit) / nRuns) * 100;
fprintf('├───────────┴──────────────────┴───────────────────┤\n');
fprintf('│         FINÁLNE ŠTATISTICKÉ VYHODNOTENIE         │\n');
fprintf('├──────────────────────────────────────┬───────────┤\n');
fprintf('│ Absolútne globálne minimum           │  %8.2f │\n', globalBestFit);
fprintf('│ Priemerná hodnota fitness            │  %8.2f │\n', mean(runResults));
fprintf('│ Celková úspešnosť riešení (pod 480)  │     %3.0f %% │\n', successRate);
fprintf('└──────────────────────────────────────┴───────────┘\n\n');

%% VIZUALIZÁCIA (Magenta & Black)
figure('Name','Optimalizačný výstup'); 
hold on;

% 1. Čierna trasa (podkladová vrstva)
hMain = plot(B(globalBestPath,1), B(globalBestPath,2), 'k-', 'LineWidth', 2, 'DisplayName', 'Optimálna trasa');

% 2. Vzdialenosti (biele bubliny v strede úsečiek)
for j = 1:(numPoints - 1)
    p1 = B(globalBestPath(j), :);
    p2 = B(globalBestPath(j+1), :);
    mid = (p1 + p2) / 2;
    d = sqrt(sum((p1 - p2).^2));
    
    text(mid(1), mid(2), sprintf('%.1f', d), 'FontSize', 8, 'FontWeight', 'bold', ...
        'Color', 'k', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', ...
        'Margin', 1, 'EdgeColor', [0.8 0.8 0.8]);
end

% 3. Magenta mestá (vykreslené POSLEDNÉ, aby boli NAVRCHU)
hNodes = plot(B(:,1), B(:,2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 10, 'DisplayName', 'Mestá (Uzly)');

% 4. Štart a Cieľ (Zvýraznenie)
hStart = plot(B(1,1), B(1,2), 'gs', 'MarkerSize', 13, 'MarkerFaceColor', 'g', 'DisplayName', 'Štart (Depo)'); 
hEnd = plot(B(25,1), B(25,2), 'rs', 'MarkerSize', 13, 'MarkerFaceColor', 'r', 'DisplayName', 'Cieľ (Koniec)'); 

% 5. Dynamická legenda so všetkými behmi
hRuns = zeros(nRuns, 1);
for r = 1:nRuns
    hRuns(r) = plot(NaN, NaN, 'o', 'MarkerSize', 4, 'Color', [0.6 0.6 0.6], ...
        'DisplayName', sprintf('Beh %02d: %.2f', r, runResults(r)));
end

% Finálne doladenie grafu
lgd = legend([hMain, hNodes, hStart, hEnd, hRuns'], 'Location', 'northeastoutside');
title(lgd, 'Log záznam behov');
grid on; box on;
axis([0 100 0 100]);
title(['\fontsize{14}Analýza trasy | Globálne minimum: ' num2str(globalBestFit, '%.2f')], 'Color', 'k');
xlabel('Súradnica X'); ylabel('Súradnica Y');