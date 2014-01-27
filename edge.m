function edge(infilename, informat, sigma, T_h, T_l)
% Input
pic = imread(strcat(infilename, '.', informat));
pic = im2double(rgb2gray(pic));

% Filtered gradient
blurpic = gaussianblur(pic,sigma,3);
[Fy, Fx, F, D] = filteredgradient(blurpic);
%[Fy, Fx, F, D] = fastfilteredgradient(pic,sigma);

filename = sprintf('%s_Fx_%d.jpg', infilename, sigma, T_h, T_l);
imwrite(Fx * 100, filename, 'jpg');
filename = sprintf('%s_Fy_%d.jpg', infilename, sigma, T_h, T_l);
imwrite(Fy * 100, filename, 'jpg');
filename = sprintf('%s_F_%d.jpg', infilename, sigma, T_h, T_l);
imwrite(F * 50, filename, 'jpg');

% Nonmaximum suppression
[height, width] = size(F);
dirs = [0, pi/4, pi/2, 3*pi/4];
Di = zeros(height, width);
for y = 1:height
    for x = 1:width
            if D(y,x) < 0
                D(y,x) = D(y,x) + pi;
            end
            Di(y,x) = 1;
            for dir = 2:4
                if abs(dirs(dir) - D(y,x)) < abs(dirs(Di(y,x)) - D(y,x))
                    Di(y,x) = dir;
                end            
            end
    end
end

dy = [0 1 1 1 0 -1 -1 -1];
dx = [1 1 0 -1 -1 -1 0 1];
I = F;
for y = 1:height
    for x = 1:width
        for dir = Di(y,x):4:Di(y,x)+4
            x1 = x + dx(dir);
            y1 = y + dy(dir);
            if  y1 < 1 || y1 > height || x1 < 1 || x1 > width
                continue;
            end
            if F(y,x) < F(y1,x1)
                I(y,x) = 0;
                break;
            end
        end
    end
end

filename = sprintf('%s_I_%d.jpg', infilename, sigma, T_h, T_l);
imwrite(I * 100, filename, 'jpg');

% Hysteresis thresholding
global visited;
visited = zeros(height, width);

set(0, 'RecursionLimit', height*width);
for y = 1:height
    for x = 1:width
        if visited(y,x) == 0 && I(y,x) > T_l
            dfs(I, y, x, dy, dx, T_l, Di);
        end
    end
end

% Print output
outpic = visited * 1000;
filename = sprintf('edges_%s_%d_%.4f_%.4f.jpg', infilename, sigma, T_h, T_l);
imwrite(outpic, filename, 'jpg');
end