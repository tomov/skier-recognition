function [gradx, grady] = HOGGradient(G)

% here we defing the mask as [-1, 0, 1], the edge of the image use [-1, 1]
[height, width] = size(G);

gradx = zeros(height, width);
grady = zeros(height, width);

% Process the Image edge
gradx(:,1) = sum(G(:,1:2).*repmat([-1, 1], height, 1), 2);
gradx(:,width) = sum(G(:, width-1:width).*repmat([-1, 1], height, 1), 2);

grady(1,:) = sum(G(1:2, :).*repmat([-1; 1], 1, width), 1);
grady(height,:) = sum(G(height-1:height, :).*repmat([-1; 1], 1, width), 1);

for j=2:height-1
    for i=2:width-1
        tmpx = G(j, i-1:i+1);
        tmpy = G(j-1:j+1, i);
        gradx(j,i) = sum(tmpx.*[-1, 0, 1], 2);
        grady(j,i) = sum(tmpy.*[-1; 0; 1], 1);
    end
end