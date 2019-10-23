function [ lbp_hist ] = lbpHist( lbp_code )
% Funct:  Calculate Histogram of LBP Map.
% Input:  lbp_code - the LBP code map.
% Output: lbp_hist - the histogram of LBP map.
% Author: Shu Wang, George Mason University.
% Date:   2019-10-22.

lbp_code_d = double(lbp_code);
valmax = max(max(lbp_code_d));

lbp_hist = hist(lbp_code_d(:), 0:valmax);  % calculate histogram.
lbp_hist = lbp_hist / sum(lbp_hist);         % normalized histogram.

end

