function [Fy, Fx, F, D] = fastfilteredgradient(pic, sigma)
    g = gauss(sigma, 3);
    gx = g(2:end, 1:end-1) - g(1:end-1, 1:end-1);
    Fx = conv2(pic, gx, 'same'); 
    gy = g(1:end-1, 2:end) - g(1:end-1, 1:end-1);
    Fy = conv2(pic, gy, 'same');
    F = sqrt(Fx.^2 + Fy.^2);
    D = atan2(Fy,Fx);
end