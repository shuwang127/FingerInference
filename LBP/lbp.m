function [ result ] = lbp( img, R, P )
% Funct:  Implementation of Local Binary Pattern (LBP).
% Input:  img - one channel gray image.
%         R - the radius of the neighbour circle.
%         P - the neighbour point number.
%           For example, R = 1, P = 8, the points are counter-clockwise.
%           4  3  2
%           5  *  1
%           6  7  8
% Output: result - the LBP map. (uint8, uint16, uint32) 
% Author: Shu Wang, George Mason University
% Date:   2019-10-22

%% Preprocess the arguments.
% process the image.
img_d = double(img);
[size_y, size_x] = size(img);

% calculate the neighbour points.
% axis in image always (y, x). y axis direction differs from the normal.
points_yx = zeros(P, 2);        % y-x coordinate of neighbours.
a = 2 * pi / P;                 % angel step.
for i = 1 : P
    points_yx(i, 1) = - R * sin((i-1) * a);  % y coordinate.
    points_yx(i, 2) = R * cos((i-1) * a);    % x coordinate.
end
clear a i;

%% Preprocess the center matrix and result matrix.
% the range of the neighbour points.
p_ymin = min(points_yx(:, 1));
p_ymax = max(points_yx(:, 1));
p_xmin = min(points_yx(:, 2));
p_xmax = max(points_yx(:, 2));
% the LBP block size.
size_by = ceil(p_ymax) - floor(p_ymin) + 1;
size_bx = ceil(p_xmax) - floor(p_xmin) + 1;
% origin y-x coordinates.
orig_y = abs(floor(p_ymin)) + 1;
orig_x = abs(floor(p_xmin)) + 1;
clear p_ymin p_ymax p_xmin p_xmax;
% center pixel traverses (0:dy, 0:dx).
dy = size_y - size_by;
dx = size_x - size_bx;
clear size_x size_y size_by size_bx;

% image matrix for center pixel.
C = img(orig_y:orig_y+dy, orig_x:orig_x+dx);
C_d = double(C);

% result matrix.
result = zeros(size(C));

%% LBP code
for i = 1 : P  % for each neighbour.
    % calculate the neighbour y-x coordinate of the origin.
    y = points_yx(i, 1) + orig_y;
    x = points_yx(i, 2) + orig_x;
    % Check if the neighbour is in a pixel.
    ry = round(y); rx = round(x);
    if (abs(y - ry) < 1e-6) && (abs(x - rx) < 1e-6)
        % the neighbour is in a pixel.
        % image matrix for neighbour pixel.
        N = img(ry:ry+dy, rx:rx+dx);
        D = (N >= C);
    else
        % the neighbour is not in a pixel.
        % Interpolation needed.
        fy = floor(y); cy = ceil(y);
        fx = floor(x); cx = ceil(x);
        ty = y - fy;
        tx = x - fx;
        % Calculate the weights.
        w1 = roundn((1 - tx) * (1 - ty), -6);
        w2 = roundn(tx * (1 - ty), -6);
        w3 = roundn((1 - tx) * ty, -6) ;
        w4 = roundn(1 - w1 - w2 - w3, -6);
        % Compute the interpolated pixel image.
        N = w1 * img_d(fy:fy+dy, fx:fx+dx) ...
            + w2 * img_d(fy:fy+dy, cx:cx+dx) ...
            + w3 * img_d(cy:cy+dy, fx:fx+dx) ...
            + w4 * img_d(cy:cy+dy, cx:cx+dx);
        % image matrix for neighbour pixel.
        N = roundn(N, -6);
        D = (N >= C_d);
    end
    
    result = result + D * 2 ^ (i-1);    % update the result matrix.
end

%% Convert LBP map to suitable format.
if (P <= 8)
    result = uint8(result);
elseif (P <= 16)
    result = uint16(result);
else
    result = uint32(result);
end

end
