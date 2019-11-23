function [w, trainacc, testacc, predicts] = PLA(traindata, trainlabel, testdata, testlabel)
% Perceptron Learning Algorithm (PLA)
% Shu Wang

%% data preparation
num = size(traindata, 1);
dim = size(traindata, 2);
traindata = [ traindata, ones(num, 1) ]; % extend data with x_0 = 1
w = zeros(1, dim + 1); % init the weight vector

%% PLA algorithm.
cnt = 0;
while (cnt < num)
    h = sign( traindata * w' ); % get predictions.
    index = find(h ~= trainlabel); % get index for prediction ~= label.
    if isempty(index) % if no sample misclassified
        break;
    end
    idx = index(randperm(numel(index),1)); % select one sample.
    w = w + trainlabel(idx) * traindata(idx, :); % update the weight.
    cnt = cnt + 1;
end

%% Evalution
h = sign( traindata * w' );
trainacc = sum(trainlabel == h) / num;
predicts = sign( [testdata, ones(size(testlabel))] * w' );
testacc = sum(testlabel == predicts) / length(testlabel);