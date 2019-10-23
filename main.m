clear; clc;
close all;

%% Set the dataset information.
datapath = './LivDet 2017';
scanner = 'GreenBit';
matpath = ['Data/', scanner, '.mat'];

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
lbpType = 'u2';
% Get LBP features for training set.
train_lbp = []; 
for i = 1 : numel(trainlabel)
    img = traindata{i};
    lbp_map = lbp(img, radius, neighbor);
    lbp_code = lbpMapping(lbp_map, neighbor, lbpType);
    lbp_hist = lbpHist(lbp_code);
    train_lbp = [train_lbp; lbp_hist];
end
% Get LBP features for testing set.
test_lbp = [];
for i = 1 : numel(testlabel)
    img = testdata{i};
    lbp_map = lbp(img, radius, neighbor);
    lbp_code = lbpMapping(lbp_map, neighbor, lbpType);
    lbp_hist = lbpHist(lbp_code);
    test_lbp = [test_lbp; lbp_hist];
end
disp('LBP Feature Extracted!');

%% Classification.
SVMSTRUCT = svmtrain(trainlabel, train_lbp);
% Evaluation
[trainpredict, acc_train, ~] = svmpredict(trainlabel, train_lbp, SVMSTRUCT);
[testpredict, acc_test, ~] = svmpredict(testlabel, test_lbp, SVMSTRUCT);
accuracy_train = acc_train(1);
accuracy_test = acc_test(1);
disp(['=============================================']);
disp(['Training Acc: ', num2str(accuracy_train), '%']);
disp(['Testing Acc: ', num2str(accuracy_test), '%']);
% Save the model
save ./Model/SVMmodel.mat SVMSTRUCT;
