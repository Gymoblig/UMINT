clc; clear; close all;

% --- Nastavenia ---
x_range = -500:10:500; % Rozsah pre vykreslenie plochy
max_starts = 30;       % Počet náhodných štartov (viacero hľadaní)
max_local_steps = 1000; % Dĺžka každého hľadania
d = 5;                % Sila náhodného skoku

% 1. Príprava 2D plochy (Schwefel)
[X, Y] = meshgrid(x_range, x_range);
% Fitness v 2D je súčet príspevkov x a y
Z = arrayfun(@(x,y) testfn3c(x) + testfn3c(y), X, Y);

% 2. Vykreslenie 3D povrchu
figure('Color', 'w');
surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Priehľadný povrch
colormap jet;
hold on; view(3); % Prepnutie do 3D pohľadu
grid on;
xlabel('x'); ylabel('y'); zlabel('F(x,y)');
title(['2D Multi-start: ', num2str(max_starts), ' hľadaní']);

best_f = inf;
best_pos = [0, 0];

% 3. Multi-start cyklus
for i = 1:max_starts
    % Náhodný štart v 2D rovine
    curr_x = -500 + 1000 * rand();
    curr_y = -500 + 1000 * rand();
    curr_f = testfn3c(curr_x) + testfn3c(curr_y);
    
    % Vykreslenie štartovacieho bodu (čierna bodka)
    plot3(curr_x, curr_y, curr_f, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    
    % Lokálne hľadanie pre daný štart
    for step = 1:max_local_steps
        % Stochastický skok v 2D (x aj y)
        new_x = curr_x + d * randn();
        new_y = curr_y + d * randn();
        
        % Hranice
        new_x = max(min(new_x, 500), -500);
        new_y = max(min(new_y, 500), -500);
        
        new_f = testfn3c(new_x) + testfn3c(new_y);
        
        % Ak je kandidát lepší, pohneme sa a nakreslíme čiaru
        if new_f < curr_f
            line([curr_x new_x], [curr_y new_y], [curr_f new_f], 'Color', 'r', 'LineWidth', 1.5);
            curr_x = new_x;
            curr_y = new_y;
            curr_f = new_f;
        end
    end
    
    % Koncový bod tohto hľadania (zelený krúžok)
    plot3(curr_x, curr_y, curr_f, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
    
    % Kontrola absolútneho víťaza
    if curr_f < best_f
        best_f = curr_f;
        best_pos = [curr_x, curr_y];
    end
end

% Zvýraznenie úplne najlepšieho bodu (veľký červený štvorec)
plot3(best_pos(1), best_pos(2), best_f, 'rs', 'MarkerSize', 15, 'LineWidth', 4);

fprintf('Absolútne minimum: [x=%.2f, y=%.2f] s hodnotou F=%.2f\n', best_pos(1), best_pos(2), best_f);