function [xi, yi] = contours(pic, sigma, n, alpha, beta, gamma, frac, x, y, recalc)
%sigma = 1; % radius of the gaussian
%n = 3; % radius of the neighborhood
%alpha = 1; % coefficient for Econt
%beta = 1; % coefficient for Ecurv
%gamma = 1; % coefficient for Eedge
%frac = 0.1; % minimum fraction of points to move
%recalc = whether we are getting x,y from user input, or from prev image


% Input
if size(pic, 3) == 3
    picgray = im2double(rgb2gray(pic));
else
    picgray = double(pic);
end

% Filtered gradient
blurpic = gaussianblur(picgray,sigma,3);
blurpic = imresize(blurpic, 0.5);
x = x * 0.5;
y = y * 0.5;

if size(x,2) < 2
    height = size(blurpic, 1);
    height = height * 0.5;
    width = height / 1.6;
    cx = size(blurpic, 1) / 2;
    cy = size(blurpic, 2) / 2;
    y = [(cx - height / 2) (cx + height / 2) (cx + height / 2) (cx - height / 2)];
    x = [(cy - width / 2) (cy - width / 2) (cy + width / 2) (cy + width / 2)];
end

[Fy, Fx, F, D] = filteredgradient(blurpic);

% Interpolate to get more points if running algo for first time on img
if recalc == 1
    x = [x x(1)];
    y = [y y(1)];
    xi = [];
    yi = [];
    for i = 1:size(x,2)-1
        length = double((x(i+1)-x(i))^2 + (y(i+1)-y(i))^2)^0.5;
        if length == 0 continue; end
        steps = length / 5;
        dx = (x(i+1) - x(i)) / steps;
        dy = (y(i+1) - y(i)) / steps;
        if dx == 0
            real_steps = size([y(i) : dy : y(i+1)], 2);
            xi = [xi double(x(i)) * ones(real_steps,1)'];
        else
            xi = [xi [x(i) : dx : x(i+1)]];
        end
        if dy == 0
            real_steps = size([x(i) : dx : x(i+1)], 2);
            yi = [yi double(y(i)) * ones(real_steps,1)'];
        else
            yi = [yi [y(i) : dy : y(i+1)]];
        end
    end
    xi = int16([xi xi(2)]);
    yi = int16([yi yi(2)]);
else
    xi = x;
    yi = y;
end

% Try to translate the curve in all directions
% use the width of the gaussian as the translation step
xxibest = xi;
yyibest = yi;
Eebest = 0;
for xx = -3 : 3
    for yy = -3 : 3
        xxi = xi + xx * sigma;
        yyi = yi + yy * sigma;
        Ee = 0;
        for i = 1 : size(xi,2)
            if (yyi(i) < 1) yyi(i) = 1; end
            if (yyi(i) > size(F,1)) yyi(i) = size(F,1); end
            if (xxi(i) < 1) xxi(i) = 1; end
            if (xxi(i) > size(F,2)) xxi(i) = size(F,2); end
            Ee = Ee + F(yyi(i), xxi(i));
        end
        if Ee > Eebest
            xxibest = xxi;
            yyibest = yyi;
            Eebest = Ee;
        end
    end
end
xi = xxibest;
yi = yyibest;

% Run algorithm
moved = size(xi, 2);
iter = 0;

while moved / size(xi,2) > frac && iter < 50
    if recalc == 1 && iter == 0
        %imshow(pic);
        imshow(blurpic);
        line(xi, yi);
        pause(1);
    else
        imshow(blurpic);
        line(xi, yi);
        pause(0.001);
    end
    
    d_avg = mean(((xi(2:end) - xi(1:end-1)).^2 + (yi(2:end) - yi(1:end-1)).^2))^0.5;
    moved = 0;
    iter = iter + 1;
    for i = 2 : size(xi,2) - 1
        E = ones(2*n+1,2*n+1,3);
        Emax = [0 0 0];
        for px = xi(i)-n : xi(i)+n
            for py = yi(i)-n : yi(i)+n
                if px < 1 || px > size(F,2) || py < 1 || py > size(F,1), continue; end
                Econt = (d_avg - double((xi(i+1)-px)^2 + (yi(i+1)-py)^2)^0.5)^2;
                Ecurv = double((xi(i+1) - 2*px + xi(i-1))^2 + (yi(i+1) - 2*py + yi(i-1))^2);
                Eedge = - F(py, px);
                E(py-yi(i)+n+1, px-xi(i)+n+1,:) = [Econt, Ecurv, Eedge];
                Emax(1) = max([Emax(1) abs(Econt)]);
                Emax(2) = max([Emax(2) abs(Ecurv)]);
                Emax(3) = max([Emax(3) abs(Eedge)]);
            end
        end
        Esum = alpha*E(:,:,1)/Emax(1) + beta*E(:,:,2)/Emax(2) + gamma*E(:,:,3)/Emax(3);
        Emin = min(min(Esum));
        for px = 1:2*n+1
            flag = 0;
            for py = 1:2*n+1
                if Esum(py, px) == Emin && px ~= n+1 && py ~= n+1
                    xi(i) = px + xi(i)-n-1;
                    yi(i) = py + yi(i)-n-1;
                    moved = moved + 1;
                    flag = 1;
                    break;
                end
            end
            if flag == 1, break; end
        end
    end
    xi(1) = xi(size(xi,2)-1);
    xi(size(xi,2)) = xi(2);
    yi(1) = yi(size(yi,2)-1);
    yi(size(yi,2)) = yi(2);
end
