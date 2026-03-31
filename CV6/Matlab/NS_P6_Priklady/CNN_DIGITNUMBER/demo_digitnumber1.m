% Demo - rozpoznávanie èíslic 0-9 (Demo Matlab)

% bez rozsirenia dat na trenovanie - augmentacia - posuv, rotacia, resize


% cesta k datasetu èíslic
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
    'nndatasets','DigitDataset');

% nacitanie dat - imageDataStore
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% zobrazenie 20 nahodnych obrazov cislic
figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end

% pocet obrazov v jednotlivych triedach
labelCount = countEachLabel(imds)

% nacitanie 1. obrazu
img = readimage(imds,1);
% rozmer obrazu
imagesize=size(img)

numTrainFiles = 50;    % pocet vzoriek na trenovanie v kazdej skupine
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

% struktura siete
layers = [
    imageInputLayer([28 28 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];

% % augmentacia - posuv, rotacia, resize
% pixelRange = [-2 2];
% scaleRange = [0.9 1.1];
% angleRange = [-15 15];
% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandRotation',angleRange, ...
%     'RandXTranslation',pixelRange, ...
%     'RandYTranslation',pixelRange, ...
%     'RandXScale',scaleRange, ...
%     'RandYScale',scaleRange);
% 
% % dataset s augmentaciou
% augimdsTrain = augmentedImageDatastore(imagesize,imdsTrain, ...
%     'DataAugmentation',imageAugmenter);


% parametre trenovania
options = trainingOptions('adam', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',50, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',20, ...
    'Verbose',false, ...
    'Plots','training-progress');

% trenovanie siete
net = trainNetwork(imdsTrain,layers,options);     % trenovanie bez augmentacie

% net = trainNetwork(augimdsTrain,layers,options);    % trenovanie s augmentaciou

% vypocet vystupu siete pre validacne (testovacie data)
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

% vypocet uspesnosti pre validacne data
accuracy = sum(YPred == YValidation)/numel(YValidation)

% Zobrazenie kontingencnej tabulky na testovacich
figure, plotconfusion(YValidation,YPred)
