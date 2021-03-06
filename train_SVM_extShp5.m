function [SVM_Model,tExtract] = train_SVM_extShp5

% Training Part
NO_SAMPLE = 30;
EACHFILE = 4; %negative sample per file

IMGPATH_POS_BW = 'Seg2 Data\POS_bw\';
IMGPATH_NEG_BW = 'Seg2 Data\NEG_bw\';
IMGPATH_POS_HSV3 = 'Seg2 Data\POS_hsv3\';
IMGPATH_NEG_HSV3 = 'Seg2 Data\NEG_hsv3\';

%load image patch from files store in pos_bw_store/pos_hsv3_store column cell
pos_bw_store{NO_SAMPLE,1} = zeros;
neg_bw_store{NO_SAMPLE,1} = zeros;
pos_hsv3_store{NO_SAMPLE,1} = zeros;
neg_hsv3_store{NO_SAMPLE,1} = zeros;

for i= 1:NO_SAMPLE
    IMG_dir_pos = strcat(IMGPATH_POS_BW,'patch_bw_POS_', ...
        int2str(i),'.mat');
    IMG_dir_neg = strcat(IMGPATH_NEG_BW,'patch_bw_NEG_', ... 
        int2str(i),'.mat');
    IMG_dir_pos2 = strcat(IMGPATH_POS_HSV3,'patch_hsv3_POS_', ...
        int2str(i),'.mat');
    IMG_dir_neg2 = strcat(IMGPATH_NEG_HSV3,'patch_hsv3_NEG_', ...
        int2str(i),'.mat');
    
    pos_bw_store{i,1} = load(IMG_dir_pos);       
    neg_bw_store{i,1} = load(IMG_dir_neg);
    pos_hsv3_store{i,1} = load(IMG_dir_pos2);       
    neg_hsv3_store{i,1} = load(IMG_dir_neg2);
            
end

tic;  %Timer Start
%   Size for initialize 
szShape = extShp5Gabor(pos_hsv3_store{1}.patch_hsv3_POS{1},...
    pos_bw_store{1}.patch_bw_POS{1});
fea_POS(NO_SAMPLE,length(szShape)) = zeros;
fea_NEG(NO_SAMPLE*EACHFILE,length(szShape)) = zeros;

j = 1;
accumTime = 0;
clear i;
for i = 1:NO_SAMPLE    
    tic;
    fea_POS(i,:) = extShp5Gabor(pos_hsv3_store{i}.patch_hsv3_POS{1},...
        pos_bw_store{i}.patch_bw_POS{1}); 
    
    j = 1+(4*(i-1));
    fea_NEG(j,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{1},...
        neg_bw_store{i}.patch_bw_NEG{1});
    fea_NEG(j+1,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{2},...
        neg_bw_store{i}.patch_bw_NEG{2});
    fea_NEG(j+2,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{3},...
        neg_bw_store{i}.patch_bw_NEG{3});
    fea_NEG(j+3,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{4},...
        neg_bw_store{i}.patch_bw_NEG{4});
end

tExtract = accumTime/NO_SAMPLE; % timer stop (feature extract)

trainFeaVec(size(fea_POS,1)+size(fea_NEG,1),...
    size(fea_POS,2)) = zeros;
trainFeaVec(1:size(fea_POS,1),:) = fea_POS;
trainFeaVec((size(fea_POS,1)+1):end,:) = fea_NEG;

responseVec(size(fea_POS,1)+size(fea_NEG,1),1) = zeros;
responseVec(1:size(fea_POS,1),1) = 1;

SVM_Model = fitcsvm(trainFeaVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);

end




