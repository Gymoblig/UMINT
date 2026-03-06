%% OPTIMALIZÁCIA TRASY PROBLÉMU OBCHODNÉHO CESTUJÚCEHO (TSP)
% Implementácia genetického algoritmu s animáciou a profesionálnym reportom.
% Zadanie: Štart [0,0] (Index 1), Cieľ [0,0] (Index 25), Jadro (2-24).

clear; clc; close all;

% --- Definícia súradníc miest (Matica B) ---
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

% --- Evolučné parametre ---
nRuns = 10;                % Počet behov 
nGen = 1500;               % Počet generácií
popSize = 200;             % Veľkosť populácie
numPoints = size(B, 1);    % Počet bodov (25)
limit = 480;               % Limit úspešnosti podľa zadania

% --- Inicializácia globálnych premenných ---
globalBestFit = inf;
globalBestPath = [];
runResults = zeros(nRuns, 1);
allFitnessHistory = zeros(nRuns, nGen); % Pre spoločný graf konvergencie

% --- Profesionálny Tabuľkový Úvod ---
fprintf('┌──────────────────────────────────────────────────┐\n');
fprintf('│      SYSTÉM PRE GENETICKÚ OPTIMALIZÁCIU TRASY      │\n');
fprintf('├──────────────────────────────────────────────────┤\n');
fprintf('│ Nastavenia: %3d behov | %4d generácií | Pop: %3d│\n', nRuns, nGen, popSize);
fprintf('├───────────┬──────────────────┬───────────────────┤\n');
fprintf('│  ID Behu  │    Stav Procesu    │ Najlepšia Fitness │\n');
fprintf('├───────────┼──────────────────┼───────────────────┤\n');

%% HLAVNÝ VÝPOČTOVÝ CYKLUS
for r = 1:nRuns
    % 1. Inicializácia populácie (Index 1 a 25 sú fixné)
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
        
        % 4. Kríženie a Mutácia (Jadro: 2 až 24)
        mix = crosord([supbest; supbest2], 1);
        mutRange = 2:numPoints-1; 
        
        mut = swappart(mix(:, mutRange), 0.1); 
        mut = invord(mut, 0.4); 
        mut = swapgen(mut, 0.1); 
        
        mix(:, mutRange) = mut;
        
        % 5. Reinsercia
        Chrom = [best; mix];
        Chrom(1, :) = runBestPath; 
    end
    
    runResults(r) = runBestFit;
    
    if runBestFit < globalBestFit
        globalBestFit = runBestFit;
        globalBestPath = runBestPath;
    end
    
    fprintf('       %8.2f      │\n', runBestFit);
end

% --- Záverečný ASCII Report ---
successRate = (sum(runResults <= limit) / nRuns) * 100;
fprintf('├───────────┴──────────────────┴───────────────────┤\n');
fprintf('│          FINÁLNE ŠTATISTICKÉ VYHODNOTENIE          │\n');
fprintf('├──────────────────────────────────────┬───────────┤\n');
fprintf('│ Absolútne globálne minimum           │  %8.2f │\n', globalBestFit);
fprintf('│ Priemerná hodnota fitness            │  %8.2f │\n', mean(runResults));
fprintf('│ Celková úspešnosť riešení (pod 480)  │      %3.0f %% │\n', successRate);
fprintf('└──────────────────────────────────────┴───────────┘\n\n');

%% GRAF 1: KONVERGENCIA (Všetky behy + Priemer)
figure('Name','Analýza konvergencie','Color','w');
hold on;
plot(allFitnessHistory', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5); % Jednotlivé behy
plot(mean(allFitnessHistory), 'r', 'LineWidth', 2.5); % Priemerná krivka
grid on;
xlabel('Generácia'); ylabel('Fitness (Dĺžka trasy)');
title('Priebeh fitness vs. Generácia (10 behov)');
legend('Individuálne behy', 'Priemerná konvergencia');

%% GRAF 2: ANIMÁCIA TRASY (Pre tvorbu GIF)
figure('Name','Animácia optimálneho riešenia','Color','w');
hold on; grid on; box on;
axis([0 100 0 100]);
xlabel('Súradnica X'); ylabel('Súradnica Y');
title(['Najlepšia trasa | Dĺžka: ' num2str(globalBestFit, '%.2f')], 'FontSize', 12);

% Vykreslenie bodov na pozadí
plot(B(:,1), B(:,2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 8);

% Vykreslenie štartu
plot(B(1,1), B(1,2), 'gs', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
text(B(1,1)+2, B(1,2)+2, 'ŠTART', 'FontWeight', 'bold', 'Color', 'g');

% Animované spájanie
for j = 1:(numPoints - 1)
    p1 = B(globalBestPath(j), :);
    p2 = B(globalBestPath(j+1), :);
    
    line([p1(1) p2(1)], [p1(2) p2(2)], 'Color', 'k', 'LineWidth', 2);
    
    % Pridanie popisku dĺžky úseku
    mid = (p1 + p2) / 2;
    d = sqrt(sum((p1 - p2).^2));
    text(mid(1), mid(2), sprintf('%.1f', d), 'FontSize', 7, 'BackgroundColor', 'w', 'HorizontalAlignment', 'center');
    
    pause(0.2); % Rýchlosť animácie
    drawnow;
end

% Zvýraznenie cieľa
plot(B(numPoints,1), B(numPoints,2), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
text(B(numPoints,1)+2, B(numPoints,2)-3, 'CIEĽ', 'FontWeight', 'bold', 'Color', 'r');

fprintf('Program úspešne dokončený. Najlepší genóm:\n');
disp(globalBestPath);
