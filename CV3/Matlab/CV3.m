%% OPTIMALIZÁCIA TRASY PROBLÉMU OBCHODNÉHO CESTUJÚCEHO (TSP)
% Implementácia genetického algoritmu s profesionálnym ASCII reportom.
% Vizualizácia: Animovaná trasa, Konvergenčný graf a Statický výstup s kompletnou legendou.

clear; clc; close all;

% --- Definícia súradníc miest ---
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

% --- Evolučné parametre ---
nRuns = 10;                % Počet behov 
nGen = 1500;               % Počet generácií
popSize = 200;             % Veľkosť populácie
numPoints = size(B, 1);    % Počet miest (25)
limit = 480;               % Limit úspešnosti

% --- Inicializácia globálnych premenných ---
globalBestFit = inf;
globalBestPath = [];
runResults = zeros(nRuns, 1);
allFitnessHistory = zeros(nRuns, nGen); % Pre graf konvergencie

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
    % 1. Inicializácia populácie
    Chrom = genPermPop(popSize, numPoints); 
    runBestFit = inf;
    
    fprintf('│    %02d     │    Spracúvam...  │', r);
    
    for gen = 1:nGen
        % 2. Fitness evaluácia
        ObjV = Fitness(Chrom, B)'; 
        
        % Sledovanie elity a histórie
        [minVal, minIdx] = min(ObjV);
        allFitnessHistory(r, gen) = minVal;
        
        if minVal < runBestFit
            runBestFit = minVal;
            runBestPath = Chrom(minIdx, :);
        end
        
        % 3. Selekcia
        best = selbest(Chrom, ObjV, [2 2 2]); 
        supbest = selbest(Chrom, ObjV, 10);
        supbest2 = seltourn(Chrom, ObjV, popSize - 16); 
        
        % 4. Kríženie a Mutácia 
        mix = crosord([supbest; supbest2], 1);
        mutRange = 2:numPoints-1; 
        
        mut = swappart(mix(:, mutRange), 0.1); 
        mut = invord(mut, 0.4); 
        mut = swapgen(mut, 0.1); 
        
        mix(:, mutRange) = mut;
        
        % 5. Reinsercia s uchovaním elity
        Chrom = [best; mix];
        Chrom(1, :) = runBestPath; 
    end
    
    runResults(r) = runBestFit;
    
    if runBestFit < globalBestFit
        globalBestFit = runBestFit;
        globalBestPath = runBestPath;
    end
    
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

%% GRAF 1: KONVERGENCIA (Bod 6 zadania)
figure('Name','Priebeh konvergencie','Color','w');
plot(allFitnessHistory', 'Color', [0.8 0.8 0.8]); hold on;
plot(mean(allFitnessHistory), 'r', 'LineWidth', 2);
grid on; xlabel('Generácia'); ylabel('Fitness (Dĺžka)');
title('Konvergencia všetkých 10 behov (červená = priemer)');

%% GRAF 2: ANIMOVANÉ VYKRESLOVANIE (Bod 7 zadania)
figure('Name','Animácia najlepšej trasy','Color','w');
hold on; grid on; box on; axis([0 100 0 100]);
xlabel('X'); ylabel('Y');
title(['Animácia trasy | Dĺžka: ' num2str(globalBestFit, '%.2f')]);
plot(B(:,1), B(:,2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 8);
for j = 1:(numPoints - 1)
    p1 = B(globalBestPath(j), :);
    p2 = B(globalBestPath(j+1), :);
    line([p1(1) p2(1)], [p1(2) p2(2)], 'Color', 'k', 'LineWidth', 2);
    pause(0.15); 
    drawnow;
end
plot(B(1,1), B(1,2), 'gs', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(B(25,1), B(25,2), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

%% GRAF 3: STATICKÝ FINÁLNY VÝSTUP (Pôvodný vizuál + Legenda)
figure('Name','Finálna optimálna trasa'); 
hold on;

% 1. Čierna trasa
hMain = plot(B(globalBestPath,1), B(globalBestPath,2), 'k-', 'LineWidth', 2, 'DisplayName', 'Optimálna trasa');

% 2. Vzdialenosti (biele bubliny)
for j = 1:(numPoints - 1)
    p1 = B(globalBestPath(j), :);
    p2 = B(globalBestPath(j+1), :);
    mid = (p1 + p2) / 2;
    d = sqrt(sum((p1 - p2).^2));
    text(mid(1), mid(2), sprintf('%.1f', d), 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'Margin', 1, 'EdgeColor', [0.8 0.8 0.8]);
end

% 3. Uzly, Štart, Cieľ
hNodes = plot(B(:,1), B(:,2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 10, 'DisplayName', 'Mestá (Uzly)');
hStart = plot(B(1,1), B(1,2), 'gs', 'MarkerSize', 13, 'MarkerFaceColor', 'g', 'DisplayName', 'Štart (Depo)'); 
hEnd = plot(B(25,1), B(25,2), 'rs', 'MarkerSize', 13, 'MarkerFaceColor', 'r', 'DisplayName', 'Cieľ (Koniec)'); 

% 4. Dynamická legenda behov (Log záznam)
hRuns = zeros(nRuns, 1);
for r = 1:nRuns
    hRuns(r) = plot(NaN, NaN, 'o', 'MarkerSize', 4, 'Color', [0.6 0.6 0.6], ...
        'DisplayName', sprintf('Beh %02d: %.2f', r, runResults(r)));
end

% Zobrazenie legendy
lgd = legend([hMain, hNodes, hStart, hEnd, hRuns'], 'Location', 'northeastoutside');
title(lgd, 'Log záznam behov');
grid on; box on; axis([0 100 0 100]);
title(['\fontsize{14}Analýza trasy | Globálne minimum: ' num2str(globalBestFit, '%.2f')], 'Color', 'k');
xlabel('Súradnica X'); ylabel('Súradnica Y');

%% --- LOKÁLNE FUNKCIE ---
function Pop = genPermPop(popSize, numPoints)
    Pop = zeros(popSize, numPoints);
    for i = 1:popSize
        Pop(i, 1) = 1;              
        Pop(i, numPoints) = numPoints; 
        Pop(i, 2:numPoints-1) = randperm(numPoints - 2) + 1;
    end
end

function Fit = Fitness(Pop, B)
    [popS, ~] = size(Pop);
    Fit = zeros(popS, 1);
    for i = 1:popS
        totalDist = 0;
        for j = 1:(size(Pop, 2) - 1)
            p1 = B(Pop(i, j), :);
            p2 = B(Pop(i, j+1), :);
            totalDist = totalDist + sqrt(sum((p1 - p2).^2));
        end
        Fit(i) = totalDist;
    end
end