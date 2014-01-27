image = imread('../data/Screen Shot 2012-01-16 at 4.00.15 PM.png');
imshow(image);

vote = zeros(size(image, 1), size(image, 2));
mr = size(image, 1) / 4;
mc = size(image, 2) / 4;
sigma = min(mr, mc);

sz = min([size(image, 1) size(image, 2)]);
for iter = 1:4
    sz = sz * 0.8;
    for row = 1 : sz / 3 : size(image, 1) - sz
        for col = 1 : sz / 3 : size(image, 2) - sz
            r1 = round(row);
            r2 = min([round(row + sz) size(image, 1)]);
            c1 = round(col);
            c2 = min([round(col + sz) size(image, 2)]);
            feat = ImgHOGFeature(image(r1:r2, c1:c2), SkipStep, BinNum, Angle, CellSize, gaussian);
            feat = feat(:)';
            feat = imresize(feat, [1 4000]);
            gr = svmclassify(svm, feat);
            fprintf('%f %f %f %d\n', iter, row, col, gr);

            if gr
                %rectangle('Position', [col, row, sz, sz], 'LineWidth', 2, 'EdgeColor', 'Green');
                cr = row + sz / 2;
                cc = col + sz / 2;
                gauss_weight = exp(-((cr - mr)^2 + (cc - mc)^2) / (2 * sigma^2));
                vote(r1:r2, c1:c2) = vote(r1:r2, c1:c2) + gauss_weight;
                imshow(image(r1:r2, c1:c2));
                pause(0.2);
            end
        end
    end
end

vote = vote / max(vote(:));



weight_total = 0;
wr = 4;
wc = 4;
spread = 0;
for row = 1 : size(image, 1)
    for col = 1 : size(image, 2)
        if vote(row, col) < 0.9, continue; end
        spread = spread + 1;
        wr = wr + row * vote(row, col);
        wc = wc + col * vote(row, col);
        weight_total = weight_total + vote(row, col);
        avg = double(image(row, col, 1))^2 + double(image(row, col, 2))^2 + double(image(row, col, 3))^2;
        avg = avg / (3 * 255^2);
        %vote(row, col) = avg;
    end
end

wr = wr / weight_total;
wc = wc / weight_total;
imshow(image);
side = sqrt(spread)/2;
rectangle('Position', [wc-side, wr-side, side*2, side*2], 'LineWidth', 2, 'EdgeColor', 'Green');