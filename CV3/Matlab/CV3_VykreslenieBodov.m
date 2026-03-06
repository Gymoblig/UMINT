% Definícia súradníc miest (Matica B)
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

figure('Color', 'w');
hold on; grid on;

% 1. Vykreslenie bodov (všetky okrem posledného, aby sme ich nekreslili 2x na seba)
plot(B(1:end-1,1), B(1:end-1,2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 8);

% 2. Pridanie čísiel k jednotlivým bodom
for i = 1:size(B, 1)
    
    if i == 1
        % Pre prvý bod vypíšeme 1 aj 25 naraz (keďže sú na rovnakom mieste)
        text(B(i,1) + 1, B(i,2) - 3, '1, 25', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
    elseif i == size(B, 1)
        % Posledný bod (25) preskočíme, lebo sme ho vypísali pri jednotke
        continue;
    else
        % Ostatné body 2 až 24
        text(B(i,1) + 2, B(i,2) + 2, num2str(i), 'FontSize', 10, 'FontWeight', 'bold');
    end
    
end

% Úprava vzhľadu grafu
title('Indexy bodov v matici B (1 a 25 sú identické)');
xlabel('Súradnica X');
ylabel('Súradnica Y');
axis([-10 110 -10 110]);
hold off;