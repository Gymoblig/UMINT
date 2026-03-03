% Parametre 10-D úlohy
D = 10; 
num = 100;
SPACE_A = [ones(1,D)*(-1000); ones(1,D)*1000];
Amp = [ones(1,D)];
max_gen = 200; 
num_runs = 10; % Number of repetitions

% Preparation for plotting
figure(1); clf; hold on; 
colors = lines(num_runs); % Get distinct colors for each run
legend_labels = cell(1, num_runs);

for run = 1:num_runs
    % Reset population and history for each run
    pop = genrpop(num, SPACE_A);
    fitness_history = zeros(1, max_gen);
    y = testfn3c(pop);  
    msg_len = 0;
    tic; % Start timer for ETF calculation
    
    fprintf('Starting Run %d/%d...\n', run, num_runs);

    for gen = 1:max_gen
        Best = selbest(pop, y, [3 3 3]);
        Rest = selsus(pop,y, 91);
        Incest = crossov(Rest, 3, 0);
        Work = mutx(Incest, 0.05, SPACE_A);   
        AditivnaMutacia = muta(Work, 0.05, Amp, SPACE_A); 
        pop = [Best;AditivnaMutacia];
        y = testfn3c(pop);
        
        [min_y, x_idx] = min(y);
        fitness_history(gen) = min_y;
        
        if mod(gen, 100) == 0
            elapsed_time = toc; 
            avg_time_per_gen = elapsed_time / gen;
            rem_gen = max_gen - gen;
            etf_seconds = rem_gen * avg_time_per_gen; 
            
            etf_h = floor(etf_seconds / 3600);
            etf_m = floor(mod(etf_seconds, 3600) / 60);
            etf_s = mod(etf_seconds, 60);
            
            fprintf(repmat('\b', 1, msg_len));
            msg = sprintf('Run: %d | Gen: %d/%d | Best: %.2f | ETF: %02dh:%02dm:%02ds', ...
                          run, gen, max_gen, min_y, etf_h, etf_m, round(etf_s));
            fprintf('%s', msg);
            msg_len = length(msg);
        end
    end
    
    % Plot current run
    plot(fitness_history, 'Color', colors(run, :), 'LineWidth', 1.2);
    
    % Store the best result for the legend
    final_best = min(fitness_history);
    legend_labels{run} = sprintf('Run %d (Best: %.2f)', run, final_best);
    
    fprintf('\nRun %d finished. Best fitness: %.4f\n\n', run, final_best);
end

% Finalize Figure 1
xlabel('Generácia'); 
ylabel('F(x)');
title('Priebeh fitness (10 behov)');
legend(legend_labels, 'Location', 'northeastoutside');
grid on;