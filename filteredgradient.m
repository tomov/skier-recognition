function [Fy, Fx, F, D] = filteredgradient(blurpic)
    Fy = blurpic(2:end,1:end-1) - blurpic(1:end-1,1:end-1);
    Fx = blurpic(1:end-1,2:end) - blurpic(1:end-1,1:end-1);
    F = sqrt(Fx.^2 + Fy.^2);
    D = atan2(Fy,Fx);
end