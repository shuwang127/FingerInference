function [ dwt_feat ] = dwtFeature( data , N )
% Get feature of energy in the wavelet transform.
% Input : data - cell{1:N} images
%         N - N-order wavelet transform.
% Output: dwt_feat - N * (3N+1) feature
% Shu Wang, 2019-11-21.


kernel = 'haar';

dwt_feat = [];
for i = 1 : length(data)
    img = data{i};
    [C, S] = wavedec2(img, N, kernel);
    [Ea, Eh, Ev, Ed] = wenergy2(C, S);
    feat = [Ea];
    for k = 1 : (N-1)
        feat(end+1) = Eh(k);
        feat(end+1) = Ev(k);
        feat(end+1) = Ed(k);
    end
    feat = feat / sum(feat);
    dwt_feat = [dwt_feat; feat];
    
    % j = 3;
    % [cH, cV, cD]=detcoef2('all', C, S, j);
    % cA = appcoef2(C, S, kernel, j);
    % 
    % figure;
    % subplot(2,2,1),imagesc(cA);colormap gray
    % subplot(2,2,2),imagesc(cH);colormap gray
    % subplot(2,2,3),imagesc(cV);colormap gray
    % subplot(2,2,4),imagesc(cD);colormap gray
end

end

