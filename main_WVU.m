clear; clc;
close all;
addpath('_LBP');
addpath('_LPQ');
addpath('_BSIF');
addpath('_DWT');
addpath('_ELM');
addpath('_KNN');
addpath('_PLA');
addpath('_DT');
addpath(genpath('_Utility'));
addpath('libsvm');
addpath('libsvm/matlab/');

%% Load training data and testing data.
% Set the dataset information.
datapath = './WVUBIOCOP2008';
scanner = 'CrossmatchR2';
matpath = ['./Data/', scanner, '.mat'];
if ~exist(matpath, 'file')
    [ data, label ] = readData_WVU( datapath, scanner );
    save(matpath, 'data', 'label');
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
    [data_lbp, ~] = lbpFeature(data, [], radius, neighbor, lbpType);
    save(lbppath, 'data_lbp');
else
    load(lbppath);
end
disp('LBP Feature Extracted!');

%% Get LPQ features.
lpqpath = ['./Data/', scanner, '_LPQ_5.mat'];
if ~exist(lpqpath, 'file')
    [data_lpq] = lpqFeature(data);
    save(lpqpath, 'data_lpq');
else
    load(lpqpath);
end
disp('LPQ Feature Extracted!');

%% Get BSIF features.
bsifpath = ['./Data/', scanner, '_BSIF_11_8.mat'];
if ~exist(bsifpath, 'file')
    [data_bsif] = bsifFeature(data);
    save(bsifpath, 'data_bsif');
else
    load(bsifpath);
end
disp('BSIF Feature Extracted!');

%% Get DWT features.
% Set DWT parameters.
dwtpath = ['./Data/', scanner, '_DWT_5.mat'];
if ~exist(dwtpath, 'file')
    [data_dwt] = dwtFeature(data, 5);
    save(dwtpath, 'data_dwt');
else
    load(dwtpath);
end
disp('DWT Feature Extracted!');

%% Emsemble features.
feat = [data_lpq, data_bsif, data_dwt];
% Shuffle data.
trainrate = 0.8;
trainnum = ceil(trainrate * numel(label));
idx = randperm(numel(label));
trainidx = idx(1:trainnum);
testidx = idx(trainnum+1:end);
%
trainfeat = feat(trainidx, :);
trainlabel = label(trainidx, :);
testfeat = feat(testidx, :);
testlabel = label(testidx, :);

%% SVM Classification.
SVMModel = fitcsvm(trainfeat, trainlabel);
% Evaluation
trainpredict = predict(SVMModel, trainfeat);
testpredict = predict(SVMModel, testfeat);
accuracy_train = sum(trainlabel == trainpredict) / length(trainlabel);
accuracy_test = sum(testlabel == testpredict) / length(testlabel);
disp(['=============================================']);
disp(['SVM Training Acc: ', num2str(accuracy_train*100), '%']);
disp(['SVM Testing Acc: ', num2str(accuracy_test*100), '%']);
% Save the model
save ./Model/SVMmodel.mat SVMModel;

%% ELM Classification.
[~, ~, TrainAcc, TestAcc, W, b, o] ...
    = elm([trainlabel, trainfeat], [testlabel, testfeat], 1, 25, 'sig');
disp(['=============================================']);
disp(['ELM Training Acc: ', num2str(100 * TrainAcc), '%']);
disp(['ELM Testing Acc: ', num2str(100 * TestAcc), '%']);
% Save the model
save ./Model/ELMmodel.mat W b o;

%% KNN Classification.
[~, acc] = knn(trainfeat, trainlabel, testfeat, testlabel);
disp(['=============================================']);
disp(['KNN algorithm with K = 1']);
disp(['The testing accuracy: ', num2str(acc*100), '%']);

%% PLA Classification.
[w, trainacc, testacc, ~] = PLA(trainfeat, trainlabel, testfeat, testlabel);
disp(['=============================================']);
disp(['PLA Training Acc: ', num2str(100 * trainacc), '%']);
disp(['PLA Testing Acc: ', num2str(100 * testacc), '%']);
% Save the model
save ./Model/PLAmodel.mat w;

%% CART Classification.
[tree, trainacc, testacc, predicts ] = DT(trainfeat, trainlabel, testfeat, testlabel);
disp(['=============================================']);
disp(['CART Training Acc: ', num2str(100 * trainacc), '%']);
disp(['CART Testing Acc: ', num2str(100 * testacc), '%']);
% Save the model
save ./Model/DTmodel.mat tree;
% Vtree = fitctree(trainfeat, trainlabel, 'CrossVal', 'on');
% view(Vtree.Trained{1}, 'Mode', 'graph');