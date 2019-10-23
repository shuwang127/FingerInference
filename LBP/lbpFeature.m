function [ train_lbp, test_lbp ] = lbpFeature( traindata, testdata, radius, neighbor, lbpType )
% Funct:  Get LBP Features for Trainset and Testset.
% Input:  traindata - train data.
%         testdata - test data.
%         radius - the radius of the neighbour circle.
%         neighbor - the neighbour point number.
%         lbpType - the mapping rule.
%                   'ri'   for rotation-invariant LBP
%                   'u2'   for uniform LBP
%                   'riu2' for uniform rotation-invariant LBP.
% Output: train_lbp - the LBP feature for training set.
%         test_lbp - the LBP feature for testing set.
% Author: Shu Wang, George Mason University
% Date:   2019-10-22

% Get LBP features for training set.
train_lbp = []; 
for i = 1 : length(traindata)
    % Read i-th image.
    img = traindata{i};
    % Get the LBP map and code map.
    lbp_map = lbp(img, radius, neighbor);
    lbp_code = lbpMapping(lbp_map, neighbor, lbpType);
    % Get the fingerprint mark.
    se = offsetstrel('ball', 7, 7);
    img_eroded = imerode(img, se);
    img_eroded_bw = im2bw(img_eroded);
    % Resize the mark.
    orig = floor((size(img_eroded_bw) - size(lbp_code)) / 2);
    sz = size(lbp_code);
    img_eroded_bw = img_eroded_bw(orig(1)+1:orig(1)+sz(1), orig(2)+1:orig(2)+sz(2));
    % Code the blank area.
    lbp_code(img_eroded_bw == 1) = intmax(class(lbp_code)); 
    % Get the histogram of LBP code.
    lbp_hist = lbpHist(lbp_code);
    % Remove the blank code and normalize.
    lbp_hist = lbp_hist(1:end-1); 
    lbp_hist = lbp_hist / sum(lbp_hist);
    % Add the LBP feature.
    train_lbp = [train_lbp; lbp_hist];
end
% Get LBP features for testing set.
test_lbp = [];
for i = 1 : length(testdata)
    % Read i-th image.
    img = testdata{i};
    % Get the LBP map and code map.
    lbp_map = lbp(img, radius, neighbor);
    lbp_code = lbpMapping(lbp_map, neighbor, lbpType);
    % Get the fingerprint mark.
    se = offsetstrel('ball', 7, 7);
    img_eroded = imerode(img, se);
    img_eroded_bw = im2bw(img_eroded);
    % Resize the mark.
    orig = floor((size(img_eroded_bw) - size(lbp_code)) / 2);
    sz = size(lbp_code);
    img_eroded_bw = img_eroded_bw(orig(1)+1:orig(1)+sz(1), orig(2)+1:orig(2)+sz(2));
    % Code the blank area.
    lbp_code(img_eroded_bw == 1) = intmax(class(lbp_code)); 
    % Get the histogram of LBP code.
    lbp_hist = lbpHist(lbp_code);
    % Remove the blank code and normalize.
    lbp_hist = lbp_hist(1:end-1); 
    lbp_hist = lbp_hist / sum(lbp_hist);
    % Add the LBP feature.
    test_lbp = [test_lbp; lbp_hist];
end

end

