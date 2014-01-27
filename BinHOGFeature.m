function binfeat = BinHOGFeature(blockGr, blockInd, CellSize, BinNum)

% devide the block
block_ori1=blockGr(1:CellSize,1:CellSize);
block_ori2=blockGr(1:CellSize,(1+CellSize):2*CellSize);
block_ori3=blockGr((1+CellSize):2*CellSize,1:CellSize);
block_ori4=blockGr((1+CellSize):2*CellSize,(1+CellSize):2*CellSize);
block_grad1=blockInd(1:CellSize,1:CellSize);
block_grad2=blockInd(1:CellSize,(1+CellSize):2*CellSize);
block_grad3=blockInd((1+CellSize):2*CellSize,1:CellSize);
block_grad4=blockInd((1+CellSize):2*CellSize,(1+CellSize):2*CellSize);

% here we calculate 4 cells
binfeat = zeros(BinNum*4, 1);
feat1 = zeros(BinNum, 1);
feat2 = zeros(BinNum, 1);
feat3 = zeros(BinNum, 1);
feat4 = zeros(BinNum, 1);

for i=1:BinNum
    feat1(i) = sum(block_ori1(find(block_grad1==i)));
end


for i=1:BinNum
    feat2(i) = sum(block_ori2(find(block_grad2==i)));
end


for i=1:BinNum
    feat3(i) = sum(block_ori3(find(block_grad3==i)));
end


for i=1:BinNum
    feat4(i) = sum(block_ori4(find(block_grad4==i)));
end

binfeat = [feat1;feat2;feat3;feat4];
% binfeat = binfeat./sum(binfeat);     % here we normallize the feature
sump=sqrt(sum(binfeat.^2));
binfeat = binfeat./(sump+eps);
end