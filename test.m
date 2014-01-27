ImgName = 'Screen Shot 2012-01-16 at 3.54.50 PM.png';
BinNum = 3;
Angle = 180;
CellSize = 10;
FilterSize = 0;
FilterDelta = 0;
feat = ImgHOGFeature(ImgName, 5, BinNum, Angle, 5, [6;3]);
