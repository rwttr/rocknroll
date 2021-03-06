% 2-features model

nRowPos = size(shapeF_Pos,1);
nRowNeg = size(shapeF_Neg,1);

nColShape = size(shapeF_Pos,2);
nColTFrr = size(textF_FRR_Pos,2);
nColTCmt = size(textF_CMT_Pos,2);
nColTHog = size(textF_HOG_Pos,2);

responseVec(nRowPos+nRowNeg,1) = zeros;
responseVec(1:nRowPos,1) = 1;
%---------------------------------------------------------------------
% 5. Shape + Texture Fourier

sTfrrVec(nRowPos+nRowNeg, nColShape+nColTFrr) = zeros;
sTfrrVec(1:nRowPos,:) = [shapeF_Pos textF_FRR_Pos];
sTfrrVec((nRowPos+1):end,:) = [shapeF_Neg textF_FRR_Neg];

SVM_sTfrr_linear = fitcsvm(sTfrrVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sTfrr_gaussian = fitcsvm(sTfrrVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sTfrr_poly = fitcsvm(sTfrrVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%---------------------------------------------------------------------
% 6. Shape + Texture Co-occurrence Matrix

sTcmtVec(nRowPos+nRowNeg, nColShape+nColTCmt) = zeros;
sTcmtVec(1:nRowPos,:) = [shapeF_Pos textF_CMT_Pos];
sTcmtVec((nRowPos+1):end,:) = [shapeF_Neg textF_CMT_Neg];

SVM_sTcmt_linear = fitcsvm(sTcmtVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sTcmt_gaussian = fitcsvm(sTcmtVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sTcmt_poly = fitcsvm(sTcmtVec,responseVec,...
    'KernelFunction','poly','KernelScale','auto','Standardize',true);
%---------------------------------------------------------------------
% 7. Shape + Texture HOG

sThogVec(nRowPos+nRowNeg, nColShape+nColTHog) = zeros;
sThogVec(1:nRowPos,:) = [shapeF_Pos textF_HOG_Pos];
sThogVec((nRowPos+1):end,:) = [shapeF_Neg textF_HOG_Neg];

SVM_sThog_linear = fitcsvm(sThogVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sThog_gaussian = fitcsvm(sThogVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sThog_poly = fitcsvm(sThogVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%--------------------------------------------------------------------
% 8. Texture FRR + Co-occurrence Matrix

tFrrCmtVec(nRowPos+nRowNeg, nColTFrr+nColTCmt) = zeros;
tFrrCmtVec(1:nRowPos,:) = [textF_FRR_Pos textF_CMT_Pos];
tFrrCmtVec((nRowPos+1):end,:) = [textF_FRR_Neg textF_CMT_Neg];

SVM_tFrrCmt_linear = fitcsvm(tFrrCmtVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tFrrCmt_gaussian = fitcsvm(tFrrCmtVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tFrrCmt_poly = fitcsvm(tFrrCmtVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%--------------------------------------------------------------------
% 9. texture FRR + HOG

tFrrHogVec(nRowPos+nRowNeg, nColTFrr+nColTHog) = zeros;
tFrrHogVec(1:nRowPos,:) = [textF_FRR_Pos textF_HOG_Pos];
tFrrHogVec((nRowPos+1):end,:) = [textF_FRR_Neg textF_HOG_Neg];

SVM_tFrrHog_linear = fitcsvm(tFrrHogVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tFrrHog_gaussian = fitcsvm(tFrrHogVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tFrrHog_poly = fitcsvm(tFrrHogVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%--------------------------------------------------------------------
% 10. Texture Co-Mat + HOG

tCmtHogVec(nRowPos+nRowNeg, nColTCmt+nColTHog) = zeros;
tCmtHogVec(1:nRowPos,:) = [textF_CMT_Pos textF_HOG_Pos];
tCmtHogVec((nRowPos+1):end,:) = [textF_CMT_Neg textF_HOG_Neg];

SVM_tCmtHog_linear = fitcsvm(tCmtHogVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tCmtHog_gaussian = fitcsvm(tCmtHogVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tCmtHog_poly = fitcsvm(tCmtHogVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%--------------------------------------------------------------------

clear nRowPos nRowNeg nColShape nColTFrr nColTCmt nColTHog responseVec
clear sTfrrVec sTcmtVec sThogVec tFrrCmtVec tFrrHogVec tCmtHogVec

