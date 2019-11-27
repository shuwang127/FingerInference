%% Emsemble features.
% LPQ  256 77.3465 30
% BSIF 256 77.7768 40
% DWT  13  79.1697 22

clear; close all;
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_BSIF_11_8.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_DWT_5.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_LBP_1_8_riu2.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_LPQ_5.mat')

%%
train_lpq = []; test_lpq = [];
train_bsif = []; test_bsif = [];
train_dwt = []; test_dwt = [];
train_all = []; test_all = [];
pre_acc = 0;
iternum = 10000;
for i = 1 : iternum
    % Shuffle data and get index.
    trainrate = 0.8;
    trainnum = ceil(trainrate * numel(label));
    idx = randperm(numel(label));
    trainidx = idx(1:trainnum);
    testidx = idx(trainnum+1:end);
    
    %% get label
    trainlabel = label(trainidx, :);
    testlabel = label(testidx, :);
    
    % LPQ
    trainfeat = data_lpq(trainidx, :);
    testfeat = data_lpq(testidx, :);
    [~, ~, TrainAcc, TestAcc, W, b, o] ...
        = elm([trainlabel, trainfeat], [testlabel, testfeat], 1, 30, 'sig');
    train_lpq(end+1) = TrainAcc;
    test_lpq(end+1) = TestAcc;
    [ p_train_lpq, ~ ] = elmforward( trainfeat, trainlabel, W, b, o, 'sig');
    [ p_test_lpq, ~ ] = elmforward( testfeat, testlabel, W, b, o, 'sig');
    m1.W = W; m1.b = b; m1.o = o;
    
    % BSIF
    trainfeat = data_bsif(trainidx, :);
    testfeat = data_bsif(testidx, :);
    [~, ~, TrainAcc, TestAcc, W, b, o] ...
        = elm([trainlabel, trainfeat], [testlabel, testfeat], 1, 40, 'sig');
    train_bsif(end+1) = TrainAcc;
    test_bsif(end+1) = TestAcc;
    [ p_train_bsif, ~ ] = elmforward( trainfeat, trainlabel, W, b, o, 'sig');
    [ p_test_bsif, ~ ] = elmforward( testfeat, testlabel, W, b, o, 'sig');
    m2.W = W; m2.b = b; m2.o = o;
    
    % DWT
    trainfeat = data_dwt(trainidx, :);
    testfeat = data_dwt(testidx, :);
    [~, ~, TrainAcc, TestAcc, W, b, o] ...
        = elm([trainlabel, trainfeat], [testlabel, testfeat], 1, 22, 'sig');
    train_dwt(end+1) = TrainAcc;
    test_dwt(end+1) = TestAcc;
    [ p_train_dwt, ~ ] = elmforward( trainfeat, trainlabel, W, b, o, 'sig');
    [ p_test_dwt, ~ ] = elmforward( testfeat, testlabel, W, b, o, 'sig');
    m3.W = W; m3.b = b; m3.o = o;
    
    % Ensemble
    p_train = p_train_lpq + p_train_bsif + p_train_dwt;
    p_train = double(p_train >= 2);
    p_test = p_test_lpq + p_test_bsif + p_test_dwt;
    p_test = double(p_test >= 2);
    
    all_acc = sum([p_test;p_train] == [testlabel;trainlabel]) / length(label);
    if all_acc > pre_acc
        pre_acc = all_acc;
        save ./Model/wModel.mat m1 m2 m3 idx
    end
    
    train_all(end+1) = sum(p_train == trainlabel) / length(trainlabel);
    test_all(end+1) = sum(p_test == testlabel) / length(testlabel);
end

%%
% Boxplot
STAT = zeros(4, 2, iternum);
STAT(1, 1, :) = train_lpq;
STAT(1, 2, :) = test_lpq;
STAT(2, 1, :) = train_bsif;
STAT(2, 2, :) = test_bsif;
STAT(3, 1, :) = train_dwt;
STAT(3, 2, :) = test_dwt;
STAT(4, 1, :) = train_all;
STAT(4, 2, :) = test_all;
h = boxplot2(STAT, 1:4);
cmap = get(0, 'defaultaxescolororder');
for ii = 1 : 2
    structfun(@(x) set(x(ii,:), 'color', cmap(ii,:), 'markeredgecolor', cmap(ii,:)), h);
end
set([h.lwhis h.uwhis], 'linestyle', '-');
set(h.out, 'marker', '.');
set(h.out, 'marker', '.');
axis([0.5,4.5,0.6,1]);

xlabel('Features')
ylabel('Accuracy');
box on;
box_vars = findall(gca, 'Tag', 'Box');
hLegend = legend(box_vars([2,1]), {'Train','Test'});
hold on; plot([0.5,4.5],[0.8,0.8],'r--');
