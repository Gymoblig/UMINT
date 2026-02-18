% 1. Definícia parametrov
x_min = -1000;
x_max = 1000;
d = 10; 

% 2. Vizualizácia funkcie (Priebeh v celom definičnom obore)
x_plot = x_min:1:x_max;
y_plot = zeros(size(x_plot));

for i = 1:length(x_plot)
    y_plot(i) = testfn3c(x_plot(i));
end

figure;
plot(x_plot, y_plot, 'b-', 'LineWidth', 1.5);
hold on;
grid on;
title('Inicializácia a vizualizácia funkcie Schwefel');
xlabel('x');
ylabel('F(x)');

% 3. Inicializácia: Náhodne vygenerovaný bod x0
% Vzorec: min + (max - min) * náhodné_číslo
x0 = x_min + (x_max - x_min) * rand();
y0 = testfn3c(x0);

% 4. Vykreslenie počiatočného bodu do grafu
plot(x0, y0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
legend('Priebeh funkcie', 'Počiatočný bod x0');

fprintf('Štartovací bod x0: %.2f\n', x0);
fprintf('Hodnota funkcie v x0: %.2f\n', y0);