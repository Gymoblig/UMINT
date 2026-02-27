% Parametre 10-D úlohy
D = 100; 
num = 300;
SPACE_A = [ones(1,D)*(-1000); ones(1,D)*1000];
%SPACE_B = [ones(1,D)*(-10); ones(1,D)*10];
pop = genrpop(num, SPACE_A);

Amp = [ones(1,D)];

max_gen = 1000; 

fitness_history = [];
y = testfn3c(pop);  

% Premenná na sledovanie dĺžky riadka pre mazanie
msg_len = 0;

for gen = 1:max_gen
    Best = selbest(pop, y, [10 10 10]);
    Rest = selsus(pop,y, 270);
    Incest = crossov(Rest, 9, 0);

    Work = mutx(Incest, 0.01, SPACE_A);   
    AditivnaMutacia = muta(Work, 0.01, Amp, SPACE_A); 
    pop = [Best;AditivnaMutacia];
    y = testfn3c(pop);

    [min_y, x] = min(y);
    fitness_history(gen) = min_y;
    if mod(gen, 50) == 0
        elapsed_time = toc; 
        avg_time_per_gen = elapsed_time / gen;
        rem_gen = max_gen - gen;
        etf_seconds = rem_gen * avg_time_per_gen; 
        
        % Prepočet na Hodiny, Minúty a Sekundy
        etf_h = floor(etf_seconds / 3600);
        etf_m = floor(mod(etf_seconds, 3600) / 60);
        etf_s = mod(etf_seconds, 60);
        
        % Vymazať predchádzajúci riadok
        fprintf(repmat('\b', 1, msg_len));
        
        % Vytvoriť novú správu
        msg = sprintf('Gen: %5d/%d | Fitness: %8.2f | ETF: %02dh:%02dm:%02ds', ...
                      gen, max_gen, min_y, etf_h, etf_m, round(etf_s));
        
        % Vypísať správu a uložiť dĺžku
        fprintf('%s', msg);
        msg_len = length(msg);
    end
end
fprintf('\n'); % Odriadkovanie po skončení cyklu


figure(2); hold on; 
plot(fitness_history, 'r-'); 
fprintf('====================================================================================================\n');
fprintf('Najlepšia fitness: %.2fs\n',min(y));
fprintf('====================================================================================================\n');
fprintf('Najlepší jedinec: %.2f\n', x);
fprintf('Súradnice:\n');
fprintf('%.4f ', pop(x,:));
fprintf('\n');
fprintf('====================================================================================================\n');

% Graf pre Bod 3 a 4 (Priebeh fitness)
figure(1); hold on; 
plot(fitness_history, 'r-', 'LineWidth', 1.2); 
xlabel('Generácia'); ylabel('F(x)');
title('Priebeh fitness (Nová Schwefelova funkcia)');
grid on;