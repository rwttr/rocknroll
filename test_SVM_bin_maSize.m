% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG

%load segmented patch into cell
%Positive Sample
%/////////////////////////////////////////////////////////////////////////
%no of sample
nbin = 2;
maSize =1;

[SVM_Shape_linear,~] = expSVM_Linear_Shape(nbin, maSize);


NO_SAMPLE_test = 20;
START_FILE_NO = 31;
IMGPATH_BW = 'Segmented Data\POS_bw\';
IMGPATH_HSV3 = 'Segmented Data\POS_hsv3\';

pos_bw_store{NO_SAMPLE_test,1} = zeros;
pos_hsv3_store{NO_SAMPLE_test,1} = zeros;

for i= 1:NO_SAMPLE_test
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_POS_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_POS_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    pos_bw_store{i,1} = load(IMG_dir_bw);
    pos_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

% extract shape feature
% size for initialize 
szShape = extShape2(pos_bw_store{1}.patch_bw_POS,nbin,maSize);
test_shF_Pos(NO_SAMPLE_test,size(szShape,2)) = zeros;

for i = 1:NO_SAMPLE_test
    test_shF_Pos(i,:) = extShape2(pos_bw_store{i}.patch_bw_POS,nbin,maSize);        
end

%//////////////////////////////////////////////////////////////////////////
% Negative Sample
IMGPATH_BW = 'Segmented Data\NEG_bw\';
IMGPATH_HSV3 = 'Segmented Data\NEG_hsv3\';

EACHFILE = 4;

neg_bw_store{NO_SAMPLE_test,1} = zeros;
neg_hsv3_store{NO_SAMPLE_test,1} = zeros;

for i= 1:NO_SAMPLE_test
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_NEG_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_NEG_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    neg_bw_store{i,1} = load(IMG_dir_bw);
    neg_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

test_shF_Neg(NO_SAMPLE_test*EACHFILE,size(szShape,2)) = zeros;


j = 1;
for i = 1:NO_SAMPLE_test
    j = 1+(4*(i-1));
    test_shF_Neg(j,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{1},nbin,maSize);
    test_shF_Neg(j+1,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{2},nbin,maSize);
    test_shF_Neg(j+2,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{3},nbin,maSize);
    test_shF_Neg(j+3,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{4},nbin,maSize);
       
       
end


test_responseVec(1:(NO_SAMPLE_test*EACHFILE)+NO_SAMPLE_test,1) = zeros;
test_responseVec(1:NO_SAMPLE_test,1) = 1;



%----------------------------------------------------------------------------------


disp('---------------------------------------------------');
disp('     Single Feature(Shape) SVM Model');
disp('---------------------------------------------------');
% test vector size
nRowPos = size(test_shF_Pos,1);
nRowNeg = size(test_shF_Neg,1);
nColShape =  size(test_shF_Pos,2);


Y = test_responseVec; % from run_extTestFeature

XShape(nRowPos+nRowNeg,nColShape) = zeros; %test feature row vector
XShape(1:nRowPos,:) = test_shF_Pos;
XShape((nRowPos+1):end,:) = test_shF_Neg;
    
[label_shape_L,~] = predict(SVM_Shape_linear,XShape);






%------------------------------------------------------------
%Test Score part - for each SVM Kernel
%------------------------------------------------------------
%True positive (Accept true samples):raw value
Tp_L = sum(label_shape_L.*Y);

%True Negaitive (Reject false samples):raw value
Tn_L = sum(imcomplement(label_shape_L).*imcomplement(Y));

%False Positive (Accept false samples):raw value //real data is wrong but model
Fp_L = sum(label_shape_L.*imcomplement(Y));

%False Negative (Reject true samples):raw value
Fn_L = sum(imcomplement(label_shape_L).*Y);     % real data is true but model reject

% Accuracy(ACC) = (Tp+Tn)/(Tp+Tn+Fp+Fn)
acc_linear =  (Tp_L+Tn_L)/(Tp_L +Tn_L +Fp_L +Fn_L);

% Precision (positive predictive value (PPV)) = Tp/(Tp+Fp)
ppv_linear = Tp_L/(Tp_L+Fp_L);

% Sensitivity, Recall, HitRate, True Positive rate = Tp/(Tp+Fn)
sen_linear = Tp_L/(Tp_L+Fn_L);

% specificity or true negative rate (TNR) = Tn/(Tn+Fp)
spci_linear = Tn_L/(Tn_L+Fp_L);


% Display Section
disp('    Linear SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_linear ppv_linear sen_linear spci_linear]);
disp('---------------------------------------------------');


   

