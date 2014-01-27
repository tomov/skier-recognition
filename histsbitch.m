images = [54 55 83];

for i = 1 : size(images,2)

[h,s,v] = rgb2hsv(haystack{images(i)});

haha = double((s > 0.7) | (v < 0.2)) .* h;

sigma = 1;
gaussw = 2 * ceil(3 * sigma) + 1;
gaussalpha = gaussw / (2 * sigma);
gaussfilter = gausswin(gaussw, gaussalpha);
h = conv2(gaussfilter, gaussfilter, h, 'same');

bins = 20;
haha = haha(:)';
len = size(haha, 2) / 3;
zomg = [haha(1:len); haha(len+1:2*len); haha(len*2+1:len*3)];
figure(i); hold on
hi = zeros(3,bins);
for j = 1 : 3
hi(j,:) = hist(zomg(j,:), bins);
hi(j,1) = 0;
hi(j) = hi(j) / sum(hi(j));
plot(hi(j));
end
hold off

hi

figure(i + size(images,2));
%imshow(haystack{images(i)});
imshow([h s v]);

end