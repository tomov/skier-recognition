%similarly HOG descriptors,output 72 dimension feature vectors
%impatch should be a patch come form a gray image 
function outp=BHOG_yw(impatch)

[rows,cols]=size(impatch);
impatch=double(impatch);
%to obtain image gradient and orientation
%      at each pixel in grad and ori.
for r=1:rows
    for c=1:cols
        if (c==1)
            xgrad=2.0*(impatch(r,c+1)-impatch(r,c));
        elseif (c==cols)
            xgrad=2.0*(impatch(r,c)-impatch(r,c-1));
        else
            xgrad=2.0*(impatch(r,c+1)-impatch(r,c-1));
        end
        if (r==1)
            ygrad=2.0*(impatch(r,c)-impatch(r+1,c));
        elseif (r==rows)
            ygrad=2.0*(impatch(r-1,c)-impatch(r,c));
        else
            ygrad=2.0*(impatch(r-1,c)-impatch(r+1,c));
        end               
        grad(r,c)= sqrt(xgrad * xgrad + ygrad * ygrad);
        %ori(r,c) = atan2(ygrad, xgrad);%return -pi~pi
        %quatitize the orientatoin(-pi~pi) to 18 bins
        ori_index(r,c)=ceil((atan2(ygrad, xgrad)+pi)*9/pi);
        if (ori_index(r,c)==0)
            ori_index(r,c)==1;
        end
    end
end
               
%divide the patch into 4 blocks
p = [];
imblock_ori1=ori_index(1:rows/2,1:cols/2);
imblock_ori2=ori_index(1:rows/2,1+cols/2:cols);
imblock_ori3=ori_index(1+rows/2:rows,1:cols/2);
imblock_ori4=ori_index(1+rows/2:rows,1+cols/2:cols);
imblock_grad1=grad(1:rows/2,1:cols/2);
imblock_grad2=grad(1:rows/2,1+cols/2:cols);
imblock_grad3=grad(1+rows/2:rows,1:cols/2);
imblock_grad4=grad(1+rows/2:rows,1+cols/2:cols);
for bin=1:18
    ind = imblock_ori1==bin;
    p = [p;sum(imblock_grad1(ind))];
end
for bin=1:18
    ind = imblock_ori2==bin;
    p = [p;sum(imblock_grad2(ind))];
end
for bin=1:18
    ind = imblock_ori3==bin;
    p = [p;sum(imblock_grad3(ind))];
end
for bin=1:18
    ind = imblock_ori4==bin;
    p = [p;sum(imblock_grad4(ind))];
end



% Normalize length of vec to 1.0.

sqlen=0.0;len=72;
sump=sqrt(sum(p.^2));
normp=p./(sump+eps);

% if(sump==0)
%     normp=zeros(len);
% else
%     normp=p./sump;
% end

% Convert float vector to integer. Assume largest value in normalized
%      vector is likely to be less than 0.5.
 for k=1:len
     outp(k)=uint8(min(255,512.0*normp(k)));
 end