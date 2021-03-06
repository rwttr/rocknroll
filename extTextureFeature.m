function [fea_frr,fea_com,fea_hog,fea_law] = extTextureFeature(I_toext_hsv3)

%{
IMGPATH = 'C:\Users\Rattachai\Desktop\tapCrop1\39.jpg';
I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value
I_toext = I_hsv3;


[r,c] = size(I_toext);
W_mask_tukey = window2(r,c,@tukeywin); 
W_mask_hamming = window2(r,c,@hamming);
W_mask_hann = window2(r,c,@hamming);% not zero at ending
I_toext_w_tukey = I_toext.*W_mask_tukey;
I_toext_w_hamming = I_toext.*W_mask_hamming;
I_toext_w_hann = I_toext.*W_mask_hann;

figure('Name','window function Mask : Tukey');
imshowpair(I_toext,I_toext_w_tukey,'montage');

figure('Name','window function Mask : Hann');
imshowpair(I_toext,I_toext_w_hann,'montage');

figure('Name','window function Mask : Hamming');
imshowpair(I_toext,I_toext_w_hamming,'montage');
%} 
IMG_SQ_RZ = 120;    % Resize size (px)
inputIMGtexture = I_toext_hsv3;

inputIMGtexture_rz = imresize(inputIMGtexture,[IMG_SQ_RZ IMG_SQ_RZ]); 
inputIMGtexture_rz_HOG = imresize(inputIMGtexture,[IMG_SQ_RZ IMG_SQ_RZ]); 
% Bicubic interpolation Resizing method

W_mask_tukey = window2(IMG_SQ_RZ,IMG_SQ_RZ,@tukeywin); 
W_mask_hamming = window2(IMG_SQ_RZ,IMG_SQ_RZ,@hamming);
W_mask_hann = window2(IMG_SQ_RZ,IMG_SQ_RZ,@hamming);% not zero at ending

%inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_tukey;
%inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_hamming;
inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_hann;

%{
figure('Name','Resized Image');
imshow(inputIMGtexture_rz);
title('Resized image');
%}

% ///////////////////////////////////////////////////////
% Texture Analysis compute on inputIMGrz
% ///////////////////////////////////////////////////////

%///////////////fea_frr//////////////////////////////////
% Structural Analysis : Fourier Transform
F_IMG = fft2(inputIMGtexture_rz);
%figure();  imagesc(abs(fftshift(F_IMG)))
rF_IMG = abs(F_IMG);    % magnitude response
rF_IMG(1,1) = 0;        % ignore zero-freqency component
%normailized fourier coefficient
nF_IMG = abs(fftshift(F_IMG))/sqrt(sumsqr(rF_IMG));
% measurement as a single feature
fenergy_I = sumsqr(nF_IMG);           % energy:e
fentro_log = nF_IMG.*log2(nF_IMG);
fentro_I = sum(sum(fentro_log,1),2);  % entropy:h
                                      % inertia:i                                       
fea_frr = [fenergy_I fentro_I];                                  

%///////////////////////////////////////////////////////

% Statistical Analysis : Co-occurrence Matrix
% Gray-Level Co-occurrence Matrices (GLCMs)
glcms = graycomatrix(inputIMGtexture_rz);
ccontrast_I = graycoprops(glcms,'Contrast');
ccorela_I = graycoprops(glcms,'Correlation');
cenergy_I = graycoprops(glcms,'Energy');
chomog_I = graycoprops(glcms,'Homogeneity');

fea_com = [ccorela_I.Correlation ...
            cenergy_I.Energy chomog_I.Homogeneity ccontrast_I.Contrast];

%///////////////////////////////////////////////////////
% HOG feature
HOG_CELLSIZE = 20;
[fea_hog,~] = extractHOGFeatures(inputIMGtexture_rz_HOG(31:90,31:90), ... 
                'CellSize',[HOG_CELLSIZE HOG_CELLSIZE]);

%///////////////////////////////////////////////////////
% Gabor filter            
 
%///////////////////////////////////////////////////////

% ///////////////////////////////////////////////////////
% Texture Analysis compute on inputIMGtexture_rz
% Law's texture masks 1980
% ///////////////////////////////////////////////////////

L5 = [1 4 6 4 1];   %Level: Centre-weighted local average
E5 = [-1 -2 0 2 1]; %Edges: 1st diff
S5 = [-1 0 2 0 -1]; %Spot: 2nd diff
R5 = [1 -4 6 -4 1]; %Ripple
%W5 = [-1 2 0 -2 1]; %Gabor wave

%Law's masks
L5E5 = L5' * E5;
E5L5 = E5' * L5;
p1 = (L5E5+E5L5)/2;

L5R5 = L5' * R5;
R5L5 = R5' * L5;
p2 = (L5R5+R5L5)/2;

L5S5 = L5' * S5;
S5L5 = S5' * L5;
p3 = (L5S5+S5L5)/2;


E5S5 = E5' * S5;
S5E5 = S5' * E5;
p4 = (E5S5+S5E5)/2;


E5R5 = E5' * R5;
R5E5 = R5' * E5;
p5 = (E5R5+R5E5)/2;

S5R5 = S5' * R5;
R5S5 = R5' * S5;
p6 = (S5R5+R5S5)/2;

E5E5 = E5' * E5;    
p7 = E5E5;

S5S5 = S5' * S5;    
p8 = S5S5;

R5R5 = R5' * R5;    
p9 = R5R5;

% convolution with mask and calculate energy
cp1 = conv2(inputIMGtexture_rz,p1);
cp2 = conv2(inputIMGtexture_rz,p2);
cp3 = conv2(inputIMGtexture_rz,p3);
cp4 = conv2(inputIMGtexture_rz,p4);
cp5 = conv2(inputIMGtexture_rz,p5);
cp6 = conv2(inputIMGtexture_rz,p6);
cp7 = conv2(inputIMGtexture_rz,p7);
cp8 = conv2(inputIMGtexture_rz,p8);
cp9 = conv2(inputIMGtexture_rz,p9);

fea_law = [sumsqr(cp1) sumsqr(cp2) sumsqr(cp3) sumsqr(cp4) ...
    sumsqr(cp5) sumsqr(cp6) sumsqr(cp7) sumsqr(cp8) sumsqr(cp9)];




            
end

