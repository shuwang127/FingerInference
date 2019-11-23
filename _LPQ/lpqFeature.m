function [ lpq_feat ] = lpqFeature( data )
%LPQFEATURE Summary of this function goes here
%   Detailed explanation goes here

lpq_feat = [];
for i = 1 : length(data)
    img = data{i};
    feat = lpq(img, 5);
    lpq_feat = [lpq_feat; feat];
end


end

