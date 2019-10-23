clear; clc;
close all;

%% Set the dataset information.
datapath = './LivDet 2017';
scanner = 'GreenBit';
matpath = ['./Data/', scanner, '.mat'];

%% Load training data and testing data.
if ~exist(matpath, 'file')
    [ traindata, trainlabel, ~, ~ ] = readData( datapath, scanner, 'train' );
    [ testdata, testlabel, ~, ~ ] = readData( datapath, scanner, 'test' );
    save(matpath, 'traindata', 'trainlabel', 'testdata', 'testlabel');
else
    load(matpath);
end
disp('Data Loaded!');

%% Get LBP features.
% Set LBP parameters.
addpath('./LBP/');
radius = 1;
neighbor = 8;
lbpType = 'riu2';
% Load LBP features.
lbppath = ['./Data/LBP_', num2str(radius), '_', num2str(neighbor), '_', lbpType, '.mat'];
if ~exist(lbppath, 'file')
    [train_lbp, test_lbp] = lbpFeature(traindata, testdata, radius, neighbor, lbpType);
    save(lbppath, 'train_lbp', 'test_lbp');
else
    load(lbppath);
end
disp('LBP Feature Extracted!');

%% Emsemble features.
trainfeat = [train_lbp];
testfeat = [test_lbp];

%% Classification.
SVMSTRUCT = svmtrain(trainlabel, trainfeat);
% Evaluation
[trainpredict, acc_train, ~] = svmpredict(trainlabel, trainfeat, SVMSTRUCT);
[testpredict, acc_test, ~] = svmpredict(testlabel, testfeat, SVMSTRUCT);
accuracy_train = acc_train(1);
accuracy_test = acc_test(1);
disp(['=============================================']);
disp(['Training Acc: ', num2str(accuracy_train), '%']);
disp(['Testing Acc: ', num2str(accuracy_test), '%']);
% Save the model
save ./Model/SVMmodel.mat SVMSTRUCT;
