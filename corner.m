function corner(infilename, informat, sigma, m, tau)
% Input
pic = imread(strcat(infilename, '.', informat));
pic = im2double(rgb2gray(pic));

% Filtered gradient
blurpic = gaussianblur(pic,sigma,3);
[Fy, Fx, F, D] = filteredgradient(blurpic);
%[Fy, Fx, F, D] = fastfilteredgradient(pic,sigma);

filename = sprintf('%s_Fx_%d.jpg', infilename, sigma);
imwrite(Fx * 100, filename, 'jpg');
filename = sprintf('%s_Fy_%d.jpg', infilename, sigma);
imwrite(Fy * 100, filename, 'jpg');
filename = sprintf('%s_F_%d.jpg', infilename, sigma);
imwrite(F * 50, filename, 'jpg');

% Finding corners
height = size(F, 1);
width = size(F, 2);
corners = zeros(height*width, 3);
corners_cnt = 0;
l2s = zeros(height, width);
g = gauss(m/2.0,1); g = g(1:m,1:m);
for y = 1:height-m+1
    for x = 1:width-m+1
        Fxsub = Fx(y:1:y+m-1, x:1:x+m-1);
        Fysub = Fy(y:1:y+m-1, x:1:x+m-1);
        Fxsub = Fxsub .* g;
        Fysub = Fysub .* g;
        sumFx2 = sum(sum(Fxsub .^ 2));
        sumFy2 = sum(sum(Fysub .^ 2));
        sumFxFy = sum(sum(Fxsub .* Fysub));
        c = [sumFx2 sumFxFy; sumFxFy sumFy2];
        l2 = min(eig(c));
        l2s(y,x) = l2;
        if l2 > tau
            corners_cnt = corners_cnt + 1;
            corners(corners_cnt,:) = [l2 y x];
        end
    end
end
corners = corners(1:corners_cnt,:);

% Nonmaximum suppresion
erased = zeros(height, width);
sort(corners, 1, 'descend');

for i = 1:size(corners,1)
    l2 = corners(i,1);
    y = corners(i,2);
    x = corners(i,3);
    if erased(y, x)
        continue;
    end
    for y1 = max([1 y-m]):min([height y+m])
        for x1 = max([1 x-m]):min([width x+m])
            if l2s(y1,x1) < l2
                erased(y1,x1) = 1;
            end
        end
    end
end

% Marking corners
markedpic = pic;
for i = 1:size(corners,1)
    y = corners(i,2);
    x = corners(i,3);
    if erased(y, x)
        continue;
    end
    rect = [max([1 y-4]) min([height y+4]); max([1 x-4]) min([width x+4])];
    markedpic(rect(1,1):rect(1,2), rect(2,1)) = 1000;
    markedpic(rect(1,1):rect(1,2), rect(2,2)) = 1000;
    markedpic(rect(1,1), rect(2,1):rect(2,2)) = 1000;
    markedpic(rect(1,2), rect(2,1):rect(2,2)) = 1000;
end

% Print output
filename = sprintf('corners_%s_%d_%d_%.4f.jpg', infilename, sigma, m, tau);
imwrite(markedpic, filename, 'jpg');
end