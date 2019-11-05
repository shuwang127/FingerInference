clear; clc;
close all;
addpath(genpath(pwd));

%% Load training data and testing data.
% Set the dataset information.
datapath = './LivDet 2017';
scanner = 'GreenBit';
matpath = ['./Data/', scanner, '.mat'];
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
radius = 1;
neighbor = 8;
lbpType = 'riu2';
% Load LBP features.
lbppath = ['./Data/', scanner, '_LBP_', num2str(radius), '_', num2str(neighbor), '_', lbpType, '.mat'];
if ~exist(lbppath, 'file')
    [train_lbp, test_lbp] = lbpFeature(traindata, testdata, radius, neighbor, lbpType);
    save(lbppath, 'train_lbp', 'test_lbp');
else
    load(lbppath);
end
disp('LBP Feature Extracted!');

%% Emsemble features.
trainfeat = [train_lbp];
testfeat  = [test_lbp];
% Shuffle data.
trainidx = randperm(numel(trainlabel));
testidx  = randperm(numel(testlabel));
trainfeat = trainfeat(trainidx, :);
trainlabel = trainlabel(trainidx, :);
testfeat = testfeat(testidx, :);
testlabel = testlabel(testidx, :);

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
