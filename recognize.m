function [indices] = recognize (haystack, query_index, hist_res, how_many)

% prealloc histogram array
huehist = zeros(length(haystack), hist_res);

% imwrite(haystack{54},'hay54.jpg'); % nice examples
% imwrite(haystack{55},'hay55.jpg');
% imwrite(haystack{83},'hay83.jpg');

% for each image
for n = 1 : length(haystack)
    
    % read image and convert to [0, 1]-valued double[][] RGB
    x = im2double(haystack{n});
    
    % convert image to [0, 1]-valued double[][] HSL
    [H, S, L] = rgb2hsv(x);
    
    % if pixel almost white or too gray-ish set its hue to 0
    H = H .* ((S > 0.7) | (L < 0.3));
    
    % mask, for the paper images; not used by the code
    % m = ((S > 0.7) | (L < 0.3));
    
    % smooth the hues a bit to kill colour noise
    sigma = 1;
    gaussWidth = 2 * ceil(3 * sigma) + 1;
    gaussAlpha = gaussWidth / (2 * sigma);
    gaussFilter = gausswin(gaussWidth, gaussAlpha);
    H = conv2(gaussFilter, gaussFilter, H, 'same');
    
    % get the hue histogram for the image
    hist = histc(reshape(H, 1, []), 1/hist_res : 1/hist_res : 1.00);
    
    % set (hue = 0) count to 0 (do not count those pixels)
    hist(1) = 0.0;
    
    % normalize histogram
    hist = hist / sum(hist);
    
    % save it
    huehist(n,:) = (hist)';
    
end

% do the same with the query image
x = im2double(query_index);
[H, S, L] = rgb2hsv(x);
H = H .* ((S > 0.7) | (L < 0.3));
sigma = 1;
gaussWidth = 2 * ceil(3 * sigma) + 1;
gaussAlpha = gaussWidth / (2 * sigma);
gaussFilter = gausswin(gaussWidth, gaussAlpha);
H = conv2(gaussFilter, gaussFilter, H, 'same');
hist = histc(reshape(H, 1, []), 1/hist_res : 1/hist_res : 1.00);
hist(1) = 0.0;
hist = hist / sum(hist);

% find the nearest images
indices = NearestNeighbours(hist, huehist, how_many);



% helper function to get nearest neighbours
    function [indices] = NearestNeighbours(what, where, howmany)
        
%         figure(1);            % same nice images again
%         plot(where(54,:));
%         figure(2);
%         plot(where(55,:));
%         figure(3);
%         plot(where(83, :));
        
        where_length = size(where, 1);
        indices = zeros(howmany, 1);
        
        % get (howmany) neighbours
        for i = 1 : howmany
            min = +Inf;
            argmin = 1;
            
            for t = 1 : where_length
                
                % use euclidean distance
                dist = norm((what - where(t, :))', 2);
                if min > dist
                    min = dist;
                    argmin = t;
                end
                
            end
            
            indices(i) = argmin;
            where(argmin, 1) = +Inf;
        end
        
    end

end
