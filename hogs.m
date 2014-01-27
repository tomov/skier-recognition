BinNum = 3;
Angle = 180;
CellSize = 10;
SkipStep = 5;
FilterSize = 0;
FilterDelta = 0;
gaussian = [10, 4]; % hsize, sigma

training = [];
group = [];


directory = '../data/';
imagefiles = dir(strcat(directory, '*'));      
nfiles = length(imagefiles);    % Number of files found
idx = 0;
for ii=1:nfiles-1
   if imagefiles(ii).name(1) == '.', continue; end
   currentfilename = strcat(directory, imagefiles(ii).name);
   if isdir(currentfilename), continue; end
   idx = idx + 1;
   idx
   currentimage = imread(currentfilename);
   positives{idx} = currentimage;
   feat = ImgHOGFeature(currentfilename, SkipStep, BinNum, Angle, CellSize, gaussian);
   feat = feat(:)';
   feat = imresize(feat, [1 4000]);
   if size(training,1) == 0, training = feat;
   else training = [training; feat];
   end
   group = [group; 1];
end


directory = '../data/no skier/';
imagefiles = dir(strcat(directory, '*'));      
nfiles = length(imagefiles);    % Number of files found
idx = 0;
for ii=1:nfiles-1
   if imagefiles(ii).name(1) == '.', continue; end
   currentfilename = strcat(directory, imagefiles(ii).name);
   if isdir(currentfilename), continue; end
   idx = idx + 1;
   idx
   currentimage = imread(currentfilename);
   negatives{idx} = currentimage;
   feat = ImgHOGFeature(currentfilename, SkipStep, BinNum, Angle, CellSize, gaussian);
   feat = feat(:)';
   feat = imresize(feat, [1 4000]);
   if size(training,1) == 0, training = feat;
   else training = [training; feat];
   end
   group = [group; 0];
end


svm = svmtrain(training, group);