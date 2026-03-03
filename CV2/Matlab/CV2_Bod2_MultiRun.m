%% Spoločné parametre 10-D úlohy
D = 10; 
SPACE_A = [ones(1,D)*(-1000); ones(1,D)*1000];
Amp = ones(1,D);
max_gen = 300; % Znížené pre rýchlosť testov, kľudne zvýš na 500
runs_per_param = 5; % Počet kriviek v jednom grafe

% Fixné (bazálne) hodnoty
base_pop_size = 100;
base_cross = 1;
base_mut = 0.05;
base_n_best = 4;

%% 1. EXPERIMENT: Variabilná veľkosť populácie
figure(1); clf; hold on;
pop_values = [20, 50, 100, 200, 500]; % Rôzne veľkosti populácie
colors = lines(length(pop_values));

fprintf('Experiment 1: Testovanie veľkosti populácie...\n');
for i = 1:length(pop_values)
    current_num = pop_values(i);
    n_rest = current_num - (base_n_best * 3);
    
    pop = genrpop(current_num, SPACE_A);
    fitness_history = zeros(1, max_gen);
    
    for gen = 1:max_gen
        y = testfn3c(pop);
        Best = selbest(pop, y, repmat(base_n_best, 1, 3));
        Rest = selsus(pop, y, n_rest);
        Incest = crossov(Rest, base_cross, 0);
        Work = mutx(Incest, base_mut, SPACE_A);
        AditMut = muta(Work, base_mut, Amp, SPACE_A);
        pop = [Best; AditMut];
        fitness_history(gen) = min(y);
    end
    plot(fitness_history, 'Color', colors(i,:), 'LineWidth', 1.5);
    legend_labels{i} = sprintf('Pop: %d', current_num);
end
title('Vplyv veľkosti populácie na konvergenciu');
xlabel('Generácia'); ylabel('Fitness'); legend(legend_labels); grid on;

%% 2. EXPERIMENT: Variabilné kríženie (Crossover points)
figure(2); clf; hold on;
cross_values = [1, 2, 3, 5, 10]; 
colors = lines(length(cross_values));

fprintf('Experiment 2: Testovanie bodov kríženia...\n');
for i = 1:length(cross_values)
    current_cross = cross_values(i);
    n_rest = base_pop_size - (base_n_best * 3);
    
    pop = genrpop(base_pop_size, SPACE_A);
    fitness_history = zeros(1, max_gen);
    
    for gen = 1:max_gen
        y = testfn3c(pop);
        Best = selbest(pop, y, repmat(base_n_best, 1, 3));
        Rest = selsus(pop, y, n_rest);
        Incest = crossov(Rest, current_cross, 0);
        Work = mutx(Incest, base_mut, SPACE_A);
        AditMut = muta(Work, base_mut, Amp, SPACE_A);
        pop = [Best; AditMut];
        fitness_history(gen) = min(y);
    end
    plot(fitness_history, 'Color', colors(i,:), 'LineWidth', 1.5);
    legend_labels_cross{i} = sprintf('Cross pts: %d', current_cross);
end
title('Vplyv počtu bodov kríženia');
xlabel('Generácia'); ylabel('Fitness'); legend(legend_labels_cross); grid on;

%% 3. EXPERIMENT: Variabilná miera mutácie
figure(3); clf; hold on;
mut_values = [0.001, 0.01, 0.05, 0.1, 0.3]; 
colors = lines(length(mut_values));

fprintf('Experiment 3: Testovanie miery mutácie...\n');
for i = 1:length(mut_values)
    current_mut = mut_values(i);
    n_rest = base_pop_size - (base_n_best * 3);
    
    pop = genrpop(base_pop_size, SPACE_A);
    fitness_history = zeros(1, max_gen);
    
    for gen = 1:max_gen
        y = testfn3c(pop);
        Best = selbest(pop, y, repmat(base_n_best, 1, 3));
        Rest = selsus(pop, y, n_rest);
        Incest = crossov(Rest, base_cross, 0);
        Work = mutx(Incest, current_mut, SPACE_A);
        AditMut = muta(Work, current_mut, Amp, SPACE_A);
        pop = [Best; AditMut];
        fitness_history(gen) = min(y);
    end
    plot(fitness_history, 'Color', colors(i,:), 'LineWidth', 1.5);
    legend_labels_mut{i} = sprintf('Mut rate: %.3f', current_mut);
end
title('Vplyv miery mutácie na stabilitu a hľadanie minima');
xlabel('Generácia'); ylabel('Fitness'); legend(legend_labels_mut); grid on;

fprintf('\nVšetky experimenty dokončené.\n');