% COS 429 Assignment 1, due 04.10.2011 
% Mihai Roman, BlobDetector2.m
%
% Blob detector with scaled threshold.
%
% file is path to image file, without extension
% fmt is the image file's extension
% blobT is the blob treshold

function [P] = BlobDetector2(imm, blobT)

global image;
image = imm;
[m, n] = size(image);

% read image and convert to gray scale double

if size(image, 3) == 3
    image = rgb2gray(image);
end
image = im2double(image);

% a is the space of all blurred images
% max i = 10 => max sigma = 16*sqrt(2) ~ 23 => max gaussWidth ~ 135
MAX_I = 10;

a = zeros(MAX_I, m,n);
for i = 1:MAX_I
    
    % compute the gaussian filter (linear) and normalize it
    sigma = sqrt(2)^(i-1);
    gaussWidth = 2 * ceil(3 * sigma) + 1;
    gaussAlpha = gaussWidth / (2 * sigma);
    gaussFilter = gausswin(gaussWidth, gaussAlpha);
    gaussFilter = gaussFilter/sum(gaussFilter);
    
    % blur the image
    a(i, :, :) = conv2(gaussFilter, gaussFilter', image, 'same');

end

% compute the differences between sigma-values
for i = 1:MAX_I-1
    a(i, :, :) = a(i+1, :, :) - a(i, :, :);
    
    % write intermediate image (debug/grade)
    % normalized for better visibility
    temp = squeeze(a(i, :, :));
    maxTemp = max(max(temp));
    if maxTemp > 0
        temp = temp / maxTemp;
    end
    imwrite(temp, strcat('_blob_', int2str(i), '.', 'png'));
end

% initialize list with an arbitrarily high length so that it (probably)
% doesn't resize
P = zeros(10000, 3);
PSize = 1;

% go through all space of differences
for i = 2:MAX_I-2
    
    % compute threshold for this smooth radius
    sigma = sqrt(2)^(i-1);
    blobT2 = blobT / sigma;
    
    for j = 2:m-1
        for k = 2:n-1
            
            % if below treshold don't even test if extremum
            if a(i, j, k) < blobT2
                continue;
            end
            
            % check if extremum
            isMax = true;
            isMin = true;
            
            for di = -1:1
                for dj = -1:1
                    for dk = -1:1
                        
                        if di == 0 && dj == 0 && dk == 0
                            continue;
                        end
                        
                        if a(i, j, k) <= a(i+di, j+dj, k+dk)
                            isMax = false;
                        end
                        if a(i, j, k) >= a(i+di, j+dj, k+dk)
                            isMin = false;
                        end
                        
                    end
                end
            end
                
            % if extremum, put on list
            if isMax == true || isMin == true
                PSize = PSize + 1;
                P(PSize, 1) = j;
                P(PSize, 2) = k;
                P(PSize, 3) = ceil(2*sigma);
            end
            
        end
    end
end

% draw squares
for i = 1:PSize
    sigma = P(i, 3);
    halfSide = sigma;
    DrawSquare(P(i, 1), P(i, 2), halfSide);
end

P = P(2:PSize,:);

% write final image
imwrite(image, strcat( '_blob_final.', 'png'));
imshow(image);

end


% helper function to draw squares around detected corners
function [] = DrawSquare(x, y, halfSide)

global image;

for i = -halfSide:halfSide
    if isValid(x+i, y+halfSide)
        image(x+i, y+halfSide) = 0.5;
    end
    if isValid(x+i, y-halfSide)
        image(x+i, y-halfSide) = 0.5;
    end
end

for j = -halfSide:halfSide
    if isValid(x+halfSide, y+j)
        image(x+halfSide, y+j) = 0.5;
    end
    if isValid(x-halfSide, y+j)
        image(x-halfSide, y+j) = 0.5;
    end
end

end


% helper function to check if a point is in image boundaries
function [valid] = isValid(x, y)

global image;
[m, n] = size(image);

if x < 1 || y < 1 || x > m || y > n
    valid = false;
else
    valid = true;
end

end
    
