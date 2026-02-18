clc; clear; close all;

% --- Nastavenia ---
x_range = -1000:1:1000;
max_iter = 30; % Počet náhodných spustení
d = 5;         % Krok hľadania

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
    x_current = randi([-1000, 1000]);
    F_current = testfn3c(x_current);
    
    % Vykreslenie štartu iterácie
    plot(x_current, F_current, 'bo', 'MarkerFaceColor', 'k');
    
    % Volanie hľadania (tvoja logika findmin)
    [x_min_found, F_min_found] = hill_climbing_search(x_current, F_current, d);
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
plot(xmin, bestmin, 'rs', 'MarkerSize', 25, 'LineWidth', 3, 'DisplayName', 'Best Global');
xlabel('x'); ylabel('y = F(x)');
title(['Multi-start Hill Climbing (', num2str(max_iter), ' pokusov)']);

% --- FUNKCIA PRE HĽADANIE ---
function [x_curr, F_curr] = hill_climbing_search(x_curr, F_curr, d)    
    while true
        x_left = x_curr - d;
        x_right = x_curr + d;

        % Ošetrenie hraníc (aby sme nevyskočili z -1000 až 1000)
        if x_left < -1000, F_left = inf; else, F_left = testfn3c(x_left); end
        if x_right > 1000, F_right = inf; else, F_right = testfn3c(x_right); end

        % Porovnanie aktuálneho bodu so susedmi
        [val, idx] = min([F_curr, F_right, F_left]);

        if idx == 2 % Doprava je to lepšie
            x_curr = x_right;
            F_curr = F_right;
        elseif idx == 3 % Doľava je to lepšie
            x_curr = x_left;
            F_curr = F_left;
        else
            % Sme v minime (ani jeden sused nie je lepší)
            plot(x_curr, F_curr, 'bo', 'MarkerFaceColor', 'g'); % Zelený bod pre lokálne minimum
            
            break;
        end

        % Vizualizácia "kráčania"
        plot(x_curr, F_curr, 'bo', 'MarkerSize', 3);
        pause(0.01); % Zrýchlil som pauzu, aby si nečakal večnosť pri 30 iteráciách
    end
end


