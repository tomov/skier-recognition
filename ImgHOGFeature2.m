function [imgHOGFeature, colLabels] = ImgHOGFeature2(database, Img, tueImg, SkipStep, BinNum, Angle, CellSize, filter_para)
% compare with ImgHOGFeature, this function use Image data instead of image name

if nargin<7
    disp('Not enough parameters!');
    return;
end
if nargin==8
    filter_hsize=filter_para(1);
    filter_delta=filter_para(2);
end

%% Gamma/Colour Normalization
% Img = imread(ImgPathName);
Img = uint8(Img);
if size(Img,3) == 3
    G = rgb2gray(Img);
else
    G = Img;
end

[height, width] = size(G);

%% Gradient and Gradient angle Computation
if filter_hsize == 0
    [GradientX,GradientY] = gradient(double(G));
else
    h=fspecial('gaussian', filter_hsize, filter_delta);
    [GradientX, GradientY] = HOGGradient(double(G));
end
% calculate the norm of gradient
Gr = sqrt(GradientX.^2+GradientY.^2);
% Calculate the angle
index = find(GradientX == 0);
GradientX(index) = 1e-5;
YX = GradientY./GradientX;
if Angle == 180, A = ((atan(YX)+(pi/2))*180)./pi; end
if Angle == 360, A = ((atan2(GradientY,GradientX)+pi).*180)./pi; end
%% Spatial / Orientation Binning
nAngle = Angle/BinNum;
IndTag = ceil(A./nAngle);

xStepNum = floor((width-2*CellSize)/SkipStep+1);
yStepNum = floor((height-2*CellSize)/SkipStep+1);
overL = SkipStep;

FeatDim = BinNum*4;
imgHOGFeature = zeros(FeatDim, xStepNum*yStepNum);
currFeat = zeros(FeatDim,1);

colLabels = zeros(xStepNum*yStepNum,1);

% BinHOG = inline('BinHOGFeature(blockGr, blockInd, CellSize, BinNum)', 'blockGr', 'blockInd', 'CellSize', 'BinNum');

for j=1:xStepNum
    for k=1:yStepNum
        x_Off = (j-1)*overL+1;
        y_Off = (k-1)*overL+1;

        % here we define each block have 4 cells
        blockGr = Gr(y_Off:y_Off+2*CellSize-1,x_Off:x_Off+2*CellSize-1);
        blockInd = IndTag(y_Off:y_Off+2*CellSize-1,x_Off:x_Off+2*CellSize-1);
        blockL = tueImg(y_Off:y_Off+2*CellSize-1,x_Off:x_Off+2*CellSize-1, :);

        % calculate the block tag and Grain of each pixel
        currFeat = BinHOGFeature(blockGr, blockInd, CellSize, BinNum);

        % calculate the feature of the block
        imgHOGFeature(:, (j-1)*yStepNum+k) = currFeat;

        if strcmp(database, 'Sowerby')
            colLabels((j-1)*yStepNum+k) = getpatchclassSowerby_full(blockL);
        elseif strcmp(database, 'MSRC_9')
            colLabels((j-1)*yStepNum+k) = getpatchclassMSRC9_full(blockL);
        else
            disp('DataBase define error!!!');
            return;
        end
    end
end