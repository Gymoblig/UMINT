close all; clear; clc;
warning('off', 'all'); 

% --- 1. NACITANIE DAT (Podla dema dermatology) ---
if exist('CTGdata.mat', 'file')
    load CTGdata.mat % natiahnem si data zo suboru
else
    error('Súbor CTGdata.mat nebol nájdený!');
end

% Prehodim riadky a stlpce, aby to sedelo pre siet (ako v deme)
inputs = NDATA';
targetLabels = typ_ochorenia(:)';
% Musim spravit z cisla triedy (1,2,3) vektor (napr. [1;0;0])
targets = full(ind2vec(targetLabels)); 


% --- 2. PRIPRAVA INDEXOV (Rozdelim si to podla diagnoz) ---
% Toto robim kvoli tomu, aby som mal v kazdej vzorke zastupene vsetky triedy
idx1 = find(targetLabels == 1);
idx2 = find(targetLabels == 2);
idx3 = find(targetLabels == 3);



% Nastavenia pre porovnavanie
model_names = {'M1', 'M2', 'M3'};
struktury = {25, 10, [20 10]}; % rozne pocty neuronov v skrytych vrstvach
repeats = 5; % kazdy model spustim 5x, nech mam priemer
summary_data = [];

% --- 3. HLAVNY CYKLUS (Trenovanie vsetkych modelov naraz) ---
for s = 1:length(struktury)
    run_results = zeros(repeats, 4); % tu si odkladam vysledky 5 behov
    bestAcc = -inf;
    
    hiddenLayerSize = struktury{s}; 
    fprintf('\n>>> Neurónová sieť: %s (Skryté vrstvy: %s) <<<\n', model_names{s}, num2str(hiddenLayerSize));
    
    for run = 1:repeats
        % Ručné miešanie dát pre 60% tréning, 20% validácia a 20% test
        p1 = idx1(randperm(length(idx1)));
        p2 = idx2(randperm(length(idx2)));
        p3 = idx3(randperm(length(idx3)));
        
        L = [length(p1), length(p2), length(p3)];
        
        % Vyberam konkretne indexy pre kazdu cast (stratifikacia - TOTO JE STACK OVERFLOW)
        trInd = [p1(1:floor(0.6*L(1))), p2(1:floor(0.6*L(2))), p3(1:floor(0.6*L(3)))];
        valInd = [p1(floor(0.6*L(1))+1 : floor(0.8*L(1))), ...
                  p2(floor(0.6*L(2))+1 : floor(0.8*L(2))), ...
                  p3(floor(0.6*L(2))+1 : floor(0.8*L(3)))];
        tsInd = [p1(floor(0.8*L(1))+1 : end), ...
                 p2(floor(0.8*L(2))+1 : end), ...
                 p3(floor(0.8*L(3))+1 : end)];

        % zrobim siet
        net = patternnet(hiddenLayerSize);
        
        % Povieme sieti, ze indexy pre data sme si vybrali sami (manualne delenie)
        net.divideFcn = 'dividerand';
        net.divideParam.trainRatio = 0.6;
        net.divideParam.valRatio = 0.2;
        net.divideParam.testRatio = 0.2;
        
        % MOJE NASTAVENIA PARAMETROV (Vyladene pre vysoku uspesnost)
        net.trainParam.goal = 1e-3;        % Chcem co najmensiu chybu
        net.trainParam.show = 20;          % Vypis kazdych 20 epoch
        net.trainParam.epochs = 300;       % Max pocet pokusov o ucenie
        %net.trainParam.min_grad = 1e-6;   % Ukonci to, ked sa uz siet nevie zlepsovat
        net.trainParam.max_fail = 100;     % Nechaj to dlhsie bezat, nech sa to poriadne nauci
        net.trainParam.showWindow = false; % Nevyhadzuj mi milion okien pocas cyklu

        % Spustim trenovanie
        [net, tr] = train(net, inputs, targets);
        
        % Hodim data do naucenej siete a zistim, co si mysli (vystupy)
        outputs = net(inputs);
        
        % Vypocet uspesnosti (Accuracy) podla vzorca z dema: 100*(1-chyba)
        c_train = confusion(targets(:,trInd), outputs(:,trInd));
        c_test = confusion(targets(:,tsInd), outputs(:,tsInd));
        
        accTr = 100*(1 - c_train);
        accTs = 100*(1 - c_test);
        
        % Odlozim si data pre Tabulku 2 (behy)
        run_results(run, :) = [tr.best_perf, tr.best_tperf, accTr, accTs];
        
        % Ked je tento beh lepsi ako tie predtym, odlozim si celu siet
        if accTs > bestAcc
            bestAcc = accTs;
            bestNet = net;
            bestTR = tr;
            bestOutputs = outputs;
            bestTestInd = tsInd;
        end
    end
    
    % VYPIS TABULKY 2 (Vysledky vsetkych 5 pokusov pre dany model)
    fprintf('Tabuľka 2: Výsledky jednotlivých behov pre %s\n', model_names{s});
    T2 = table((1:repeats)', run_results(:,1), run_results(:,2), run_results(:,3), run_results(:,4), ...
        'VariableNames', {'Beh', 'Train_Performance', 'Test_Performance', 'Train_Acc_Percent', 'Test_Acc_Percent'});
    disp(T2);
    
    % Data pre velku suhrnnu Tabulku 3 (priemery a extremy)
    summary_data = [summary_data; {model_names{s}, min(run_results(:,4)), max(run_results(:,4)), ...
                    mean(run_results(:,4)), mean(run_results(:,2))}];
end


% --- 4. SUHRNNA TABULKA 3 (Vysledok celej ulohy) ---
fprintf('\n==========================================================\n');
fprintf('Tabuľka 3: Súhrnné porovnanie modelov (Cieľ > 92%%)\n');
fprintf('==========================================================\n');
T3 = cell2table(summary_data, 'VariableNames', {'Model', 'Min_Test_Acc', 'Max_Test_Acc', 'Priemer_Test_Acc', 'Priemer_Test_Perf'});
disp(T3);

% --- 5. DOPLNKOVE METRIKY (Bod 12 a 13 v zadani) ---
% Matrix zmatkov (confusion matrix) pre triedu 3 - patologicky stav
[c, cm] = confusion(targets(:,bestTestInd), bestOutputs(:,bestTestInd));

% Vypocet senzitivity a specificity (vztahy TP, FP, FN, TN)
TP = cm(3,3); 
FP = sum(cm(:,3)) - TP; 
FN = sum(cm(3,:)) - TP; 
TN = sum(cm(:)) - (TP + FP + FN);

fprintf('\n--- Finálne metriky pre Triedu 3 (Patologický stav) ---\n');
fprintf('Celková úspešnosť na testovacích dátach: %.4f %%\n', 100*(1-c));
fprintf('Senzitivita (TPR): %.2f %% - kolko chorych sme nasli\n', (TP / (TP + FN)) * 100);
fprintf('Špecificita (TNR): %.2f %% - ako presne urcujeme zdravych\n', (TN / (TN + FP)) * 100);

% Vykreslim confusion matrix pre najlepsi beh
figure, plotconfusion(targets(:,bestTestInd), bestOutputs(:,bestTestInd));
idx1NEW = find(targetLabels == 1,1);
idx2NEW = find(targetLabels == 2,1);
idx3NEW = find(targetLabels == 3,1);
samples = inputs(:, [idx1NEW idx2NEW idx3NEW]);
outnetsimbody = sim(net, samples);
triedy = vec2ind(outnetsimbody);
disp(outnetsimbody)
disp(triedy);