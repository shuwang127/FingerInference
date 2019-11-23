function [ bsif_feat ] = bsifFeature( data )
%BSIFFEATURE Summary of this function goes here
%   Detailed explanation goes here

filename = ['_BSIF/texturefilters/ICAtextureFilters_7x7_12bit'];
load(filename, 'ICAtextureFilters');

bsif_feat = [];
for i = 1 : length(data)
    img = data{i};
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % normalized BSIF code word histogram
    bsifhistnorm = bsif(double(img), ICAtextureFilters, 'nh');
    bsif_feat = [bsif_feat; bsifhistnorm];
end

end

