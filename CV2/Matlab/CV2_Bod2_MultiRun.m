% Parametre 10-D úlohy
D = 10; 
num = 100;
SPACE_A = [ones(1,D)*(-1000); ones(1,D)*1000];
Amp = [ones(1,D)];
max_gen = 300; 

run = 5;

% Príprava grafu
figure(2); clf; hold on;
colors = lines(run); % Generuje 10 rôznych farieb
legend_entries = cell(1, run);

fprintf('Štart %d behov s variabilnými parametrami...\n',run);

for beh = 1:run
    % --- Dynamické menenie parametrov pre každý beh (Bod 5) ---
    % Mierne variácie v počte vyvolených, krížení a miere mutácie
    n_best = 2 + mod(beh, 3);          % Mení sa medzi 2-4 
    n_rest = 100 - (n_best * 3);       % Dopočet pre selsus
    cross_points = 1 + mod(beh, 3);    % Kríženie 1 až 3 bodové
    mut_rate = 0.01 + (beh * 0.01);    % Miera mutácie od 2% 
    
    % Inicializácia behu
    pop = genrpop(num, SPACE_A);
    fitness_history = zeros(1, max_gen);
    msg_len = 0;
    tic; 

    for gen = 1:max_gen
        y = testfn3c(pop);  
        
        % Selekcia (Best, Rest)
        Best = selbest(pop, y, repmat(n_best, 1, 3));
        Rest = selsus(pop, y, n_rest);
        
        % Kríženie (Incest)
        Incest = crossov(Rest, cross_points, 0);
        
        % Mutácie (Work, AditivnaMutacia)
        Work = mutx(Incest, mut_rate, SPACE_A);   
        AditivnaMutacia = muta(Work, mut_rate, Amp, SPACE_A); 
        
        pop = [Best; AditivnaMutacia];
        [min_y, x_idx] = min(y);
        fitness_history(gen) = min_y;
        
        % Real-time výpis v jednej línii
        if mod(gen, 50) == 0
            elapsed = toc;
            etf_s = (elapsed / gen) * (max_gen - gen);
            fprintf(repmat('\b', 1, msg_len));
            msg = sprintf('Beh: %2d/10 | Gen: %4d | Fit: %8.2f | ETF: %02dm:%02ds', ...
                          beh, gen, min_y, floor(etf_s/60), round(mod(etf_s,60)));
            fprintf('%s', msg);
            msg_len = length(msg);
        end
    end
    
    % Vykreslenie behu (Bod 4)
    plot(fitness_history, 'Color', colors(beh,:), 'LineWidth', 1.2);
    legend_entries{beh} = sprintf('Beh %d (Mut: %.2f)', beh, mut_rate);
    fprintf('\nBeh %d dokončený. Najlepšia fitness: %.2f\n', beh, min(y));
end

% Finálna úprava grafu
xlabel('Generácia'); ylabel('F(x)');
title('Porovnanie %d behov GA s rôznymi parametrami',run);
legend(legend_entries, 'Location', 'northeastoutside');
grid on;

% Finálny výpis posledného (najlepšieho) jedinca
[final_min, final_idx] = min(y);
fprintf('\n======================= POSLEDNÝ BEH =======================\n');
fprintf('Najlepšia fitness: %.2f\n', final_min);
fprintf('Súradnice optimálneho jedinca:\n');
fprintf('%.4f ', pop(final_idx,:));
fprintf('\n============================================================\n');