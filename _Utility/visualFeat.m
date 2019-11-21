function [ ] = visualFeat( trainfeat, trainlabel )
% Funct:  visualize the features for each class.
% Input:  trainfeat - The feature matrix.
%         trainlabel - The label vector.
% Output: None.
% Author: Shu Wang, George Mason University.
% Date:   2019-10-24.

figure();
dim = size(trainfeat, 2);
for i = 1 : numel(trainlabel)
    if trainlabel(i) == 1
        plot(1:dim, trainfeat(i,:), 'r');
        hold on;
    elseif trainlabel(i) == 0
        plot(1:dim, trainfeat(i,:), 'b');
        hold on;
    end
end

end

