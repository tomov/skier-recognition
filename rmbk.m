% locate skiers in database of images
% and return rectangles containing them
function [ret] = rmbk(haystack)

for i = 1 : length(haystack)
    ret{i} = rmbk1(haystack{i});
end

end


% locate skier in single image
function [ret] = rmbk1(image)

ii = rgb2hsv(image);

level = graythresh(image);
BW = im2bw(image,0.3);
imshow(BW)


temp = ii(:,:,2);
temp = temp(:);
P = BlobDetector2(BW, 0.5);

%contours(BW, 3, 20, 1, 3, 1, 0.1, [], [], 1);

% repeat 3 times to get rid of outliers
for iter = 1:3
    % find blob center
    cx = 0;
    cy = 0;
    weight = 0;
    for i = 1 : size(P,1)
        cx = cx + P(i,1) * P(i,3);
        cy = cy + P(i,2) * P(i,3);
        weight = weight + P(i,3);
        %weight = weight + 1;
    end
    cx = cx / weight;
    cy = cy / weight;

    %find blob stddev (x2)
    xsigma = 0;
    ysigma = 0;
    for i = 1 : size(P,1)
        xsigma = xsigma + ( (P(i,1) - cx)^2 ) * P(i,3);
        ysigma = ysigma + P(i,3) * (P(i,2) - cy)^2;
    end
    xsigma = sqrt(xsigma / weight);
    ysigma = sqrt(ysigma / weight);
    xsigma = xsigma * 2;
    ysigma = ysigma * 2;

    % draw rectangle 2 std dev's wide
    rectangle('Position', [cy-ysigma, cx-xsigma, 2*ysigma, 2*xsigma], 'LineWidth', 2, 'EdgeColor', 'Green');
    pause(0.01);

    % draw outliers towards center
    for i = 1 : size(P,1)
        if abs(P(i,1) - cx) > xsigma || abs(P(i,2) - cy) > ysigma
            P(i,1) = cx;
            P(i,2) = cy;
        end
    end

end

% get rectangle with skier    
minx = max(1, cx - xsigma);
maxx = min(size(image, 1), cx + ysigma);
miny = max(1, cy - ysigma);
maxy = min(size(image, 2), cy + ysigma);

ret = image(minx:maxx, miny:maxy, :);
end