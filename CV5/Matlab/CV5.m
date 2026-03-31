%% 1. Načítanie dát (Bod 1)
load databody.mat
% Spojenie všetkých dát do jednej matice a transponovanie
datainnet = [data1; data2; data3; data4; data5]';
% Vytvorenie cieľov (Targety) - každá skupina má 50 bodov
dataoutnet = [ones(1,50) zeros(1,200); zeros(1,50) ones(1,50) zeros(1,150); ...
              zeros(1,100) ones(1,50) zeros(1,100); zeros(1,150) ones(1,50) zeros(1,50); ...
              zeros(1,200) ones(1,50)];


%% 2. Vytvorenie a nastavenie siete (Bod 2 a 3)
% Najjednoduchšia sieť - len 5 neurónov
net = patternnet(10);

% Rozdelenie dát: 80% trénovanie, 20% testovanie (validácia 0%)
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0;
net.divideParam.testRatio = 0.2;

% Ukončovacie podmienky
net.trainParam.epochs = 100;
net.trainParam.goal = 1e-6;


%% 3. Trénovanie a zobrazenie chýb (Bod 4)
[net, tr] = train(net, datainnet, dataoutnet);

% Graf priebehu chyby (Loss vs Epoch)
%figure; 
plotperf(tr); 
title('Priebeh chyby (Loss vs Epoch)');

% Kontingenčná matica (Confusion Matrix)
outnetsim = sim(net, datainnet);
figure(1); 
plotconfusion(dataoutnet, outnetsim);


%% 4. Testovanie 5 nových bodov (Bod 5)
bodynew = [0.55 0.25 0.2; 0.3 0.4 0.7; 0.2 0.7 0.5; 0.7 0.55 0.35; 0.9 0.85 0.4];
outnetsimbody = sim(net, bodynew') % Vypíše pravdepodobnosti do Command Window
triedy = vec2ind(outnetsimbody)    % Vypíše čísla tried (1 až 5)


% Grafické znázornenie
figure;
plot3(data1(:,1),data1(:,2),data1(:,3),'b+'); hold on;
plot3(data2(:,1),data2(:,2),data2(:,3),'co');
plot3(data3(:,1),data3(:,2),data3(:,3),'g*');
plot3(data4(:,1),data4(:,2),data4(:,3),'r*');
plot3(data5(:,1),data5(:,2),data5(:,3),'mx');

% Vykreslenie nových bodov ako veľké štvorce
farby = 'bcgrm';
for i = 1:5
    plot3(bodynew(i,1), bodynew(i,2), bodynew(i,3), [farby(triedy(i)) 's'], 'MarkerSize', 15, 'LineWidth', 2);
end
title('Klasifikácia nových bodov (štvorce)'); grid on;