% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG
run_extFeature;
run_extTestFeature;
run_SVM_2;
disp('---------------------------------------------------');
disp('    2-Features(Texture Co-Mat + HOG) SVM Model');
disp('---------------------------------------------------');
% test vector size
nRowPos = size(test_shF_Pos,1);
nRowNeg = size(test_shF_Neg,1);
nColShape =  size(test_shF_Pos,2);
nCol_T_FRR = size(test_teF_FRR_Pos,2);
nCol_T_CMT = size(test_teF_CMT_Pos,2);
nCol_T_HOG = size(test_teF_HOG_Pos,2);

Y = test_responseVec; % from run_extTestFeature

X(nRowPos+nRowNeg,nCol_T_CMT + nCol_T_HOG) = zeros; %test feature row vector
X(1:nRowPos,:) = [test_teF_CMT_Pos test_teF_HOG_Pos];
X((nRowPos+1):end,:) = [test_teF_CMT_Neg test_teF_HOG_Neg];
    
[label_L,~] = predict(SVM_tCmtHog_linear,X);
[label_G,~] = predict(SVM_tCmtHog_gaussian,X);
[label_P,~] = predict(SVM_tCmtHog_poly,X);

%------------------------------------------------------------
%Test Score part - for each SVM Kernel
%------------------------------------------------------------
%True positive (Accept true samples):raw value
Tp_L = sum(label_L.*Y);
Tp_G = sum(label_G.*Y);
Tp_P = sum(label_P.*Y);

%True Negaitive (Reject false samples):raw value
Tn_L = sum(imcomplement(label_L).*imcomplement(Y));
Tn_G = sum(imcomplement(label_G).*imcomplement(Y));
Tn_P = sum(imcomplement(label_P).*imcomplement(Y));

%False Positive (Accept false samples):raw value
Fp_L = sum(label_L.*imcomplement(Y));
Fp_G = sum(label_G.*imcomplement(Y));
Fp_P = sum(label_P.*imcomplement(Y));

%False Negative (Reject true samples):raw value
Fn_L = sum(imcomplement(label_L).*Y);
Fn_G = sum(imcomplement(label_G).*Y);
Fn_P = sum(imcomplement(label_P).*Y);

% Accuracy(ACC) = (Tp+Tn)/(Tp+Tn+Fp+Fn)
acc_linear =  (Tp_L+Tn_L)/(Tp_L +Tn_L +Fp_L +Fn_L);
acc_gaussian = (Tp_G+Tn_G)/(Tp_G +Tn_G +Fp_G +Fn_G);
acc_polynomial = (Tp_P+Tn_P)/(Tp_P +Tn_P +Fp_P +Fn_P);

% Precision (positive predictive value (PPV)) = Tp/(Tp+Fp)
ppv_linear = Tp_L/(Tp_L+Fp_L);
ppv_gaussian = Tp_G/(Tp_G+Fp_G);
ppv_polynomial = Tp_P/(Tp_P+Fp_P);

% Sensitivity, Recall, HitRate, True Positive rate = Tp/(Tp+Fn)
sen_linear = Tp_L/(Tp_L+Fn_L);
sen_gaussian = Tp_G/(Tp_G+Fn_G);
sen_polynomial = Tp_P/(Tp_P+Fn_P);

% specificity or true negative rate (TNR) = Tn/(Tn+Fp)
spci_linear = Tn_L/(Tn_L+Fp_L);
spci_gaussian = Tn_G/(Tn_G+Fp_G);
spci_polynomial = Tn_P/(Tn_P+Fp_P);

% Display Section
disp('    Linear SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_linear ppv_linear sen_linear spci_linear]);
disp('---------------------------------------------------');

disp('    Gaussian SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_gaussian ppv_gaussian sen_gaussian spci_gaussian]);
disp('---------------------------------------------------');

disp('    Polynomial(3rd order) SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_polynomial ppv_polynomial sen_polynomial spci_polynomial]);
disp('---------------------------------------------------');
   

