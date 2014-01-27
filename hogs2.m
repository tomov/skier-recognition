BinNum = 3;
Angle = 180;
CellSize = 5;
SkipStep = 4;
FilterSize = 0;
FilterDelta = 0;
gaussian = [4, 2]; % hsize, sigma

global training;
global group;
%training = [];
%group = [];
stop = 0;

directory = '../data/';
imagefiles = dir(strcat(directory, '*'));      
nfiles = length(imagefiles);    % Number of files found
idx = 57;
for ii=58:nfiles - 1
   if imagefiles(ii).name(1) == '.', continue; end
   currentfilename = strcat(directory, imagefiles(ii).name);
   if isdir(currentfilename), continue; end
   idx = idx + 1;
   idx
   image = imread(currentfilename);
   
   sz = 100;
   %for iter = 1:4
   % sz = sz * 0.9;
    for row = 1 : sz : size(image, 1) - sz / 2
        for col = 1 : sz : size(image, 2) - sz / 2
            r1 = round(row);
            r2 = min([round(row + sz) size(image, 1)]);
            c1 = round(col);
            c2 = min([round(col + sz) size(image, 2)]);
            subimage = image(r1:r2, c1:c2,:);
            imshow(subimage);
            size(subimage)
            
            w = waitforbuttonpress;
            ch = get(gcf,'CurrentCharacter');
            if ch == 'b', stop = 1;
            else
                if ch == 'y', group = [group; 1]; 
                else
                    group = [group; 0]; 
                end
            end
        
            
            if stop == 1, break; end
            feat = ImgHOGFeature(subimage, SkipStep, BinNum, Angle, CellSize, gaussian);
            feat = feat(:)';
            feat = imresize(feat, [1 1455]);
            if size(training,1) == 0, training = feat;
            else            
                training = [training; feat];
            end            
        end
        if stop == 1, break; end
    end
   %end

   positives{idx} = image;
   if stop == 1, break; end
end


%directory = '../data/no skier/';
%imagefiles = dir(strcat(directory, '*'));      
%nfiles = length(imagefiles);    % Number of files found
%idx = 0;
%for ii=1:nfiles-1
%   if imagefiles(ii).name(1) == '.', continue; end
%   currentfilename = strcat(directory, imagefiles(ii).name);
%   if isdir(currentfilename), continue; end
%   idx = idx + 1;
%   idx
%   currentimage = imread(currentfilename);
%   negatives{idx} = currentimage;
%   feat = ImgHOGFeature(currentfilename, SkipStep, BinNum, Angle, CellSize, gaussian);
%   feat = feat(:)';
%   feat = imresize(feat, [1 4000]);
%   if size(training,1) == 0, training = feat;
%   else training = [training; feat];
%   end
%   group = [group; 0];
%end


%svm = svmtrain(training, group);