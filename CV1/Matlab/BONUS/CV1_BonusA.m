clc; clear; close all;

% --- Nastavenia ---
x_range = -1000:1:1000;
max_iter = 30;          % Počet náhodných reštartov (Multi-start)
d = 10;                 % Smerodajná odchýlka pre náhodný skok
max_local_steps = 100;  % Počet pokusov o skok v každej iterácii

% 1. Vykreslenie základnej funkcie
figure;
y_plot = arrayfun(@(v) testfn3c(v), x_range);
plot(x_range, y_plot, 'r', 'LineWidth', 1);
hold on; grid on;

bestmin = inf;
xmin = inf;

% 2. Multi-start cyklus
for i = 1:max_iter
    % Náhodný štartovací bod (čierny bod)
    x_current = x_range(1) + (x_range(end) - x_range(1)) * rand();
    F_current = testfn3c(x_current);
    
    % Vykreslenie štartu iterácie
    plot(x_current, F_current, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
    
    % VOLANIE STOCHASTICKÉHO HĽADANIA (opravené parametre)
    [x_min_found, F_min_found] = stochastic_hill_climbing(x_current, F_current, d, max_local_steps);
    
    fprintf("Iterácia %d ukončená v minime: x=%.2f, F(x)=%.4f\n", i, x_min_found, F_min_found);
    
    % Kontrola, či je toto minimum lepšie ako doterajšie najlepšie
    if F_min_found < bestmin
        bestmin = F_min_found;
        xmin = x_min_found;
    end
end

% 3. Záverečný výpis
fprintf("\n==============================================");
fprintf("\nNajmenšie nájdené minimum (Global): \nx = %.4f \nF(x) = %.4f\n", xmin, bestmin);
fprintf("==============================================\n");

% Zvýraznenie absolútne najlepšieho bodu v grafe
plot(xmin, bestmin, 'rs', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Best Global');
xlabel('x'); ylabel('y = F(x)');
title(['Stochastický Multi-start Hill Climbing (', num2str(max_iter), ' pokusov)']);

% --- OPRAVENÁ STOCHASTICKÁ FUNKCIA ---
function [x_curr, F_curr] = stochastic_hill_climbing(x_curr, F_curr, d, max_local_iters)
    for j = 1:max_local_iters
        % Generujeme kandidáta: aktuálna pozícia + náhodný šum
        x_candidate = x_curr + d * randn(); 
        
        % Ošetrenie hraníc
        if x_candidate < -1000, x_candidate = -1000; end
        if x_candidate > 1000, x_candidate = 1000; end
        
        F_candidate = testfn3c(x_candidate);
        
        % Ak je kandidát lepší, presunieme sa tam
        if F_candidate < F_curr
            x_curr = x_candidate;
            F_curr = F_candidate;
            
            % Vykreslenie kroku (modrá bodka)
            plot(x_curr, F_curr, 'b.', 'MarkerSize', 5);
        end
    end
    % Konečný bod lokálneho hľadania označíme zelenou
    plot(x_curr, F_curr, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
    drawnow; % Aktualizuje graf priebežne
end