
%{ 
        read all image patches


NO_FILE = 50;
IMGPATH_BW = 'Seg2 Data\POS_bw\';
IMGPATH_HSV3 = 'Seg2 Data\POS_hsv3\';
pos_bw_store{NO_FILE,1} = zeros;
pos_hsv3_store{NO_FILE,1} = zeros;

for i= 1:NO_FILE
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_POS_',int2str(i),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_POS_',int2str(i),'.mat');
    pos_bw_store{i,1} = load(IMG_dir_bw);
    pos_hsv3_store{i,1} = load(IMG_dir_hsv3);
    imgcell_bw{i} = pos_bw_store{i,1}.patch_bw_POS{1,1};
    imgcell_hsv3{i} = pos_hsv3_store{i,1}.patch_hsv3_POS{1,1};
    [feacellV2{i},pt_cellV2{i}]=extShape2(imgcell_bw{i},2,11);
    [feacellV3{i},pt_cellV3{i}]=extShape3(imgcell_bw{i},2,11);
end
%}

patch_no = 1;

I_smooth{1} = imgcell_hsv3{patch_no};
I_smooth{2} = imgaussfilt(imgcell_hsv3{patch_no},0.5);
I_smooth{3} = imgaussfilt(imgcell_hsv3{patch_no},1);
I_smooth{4} = imgaussfilt(imgcell_hsv3{patch_no},2);
I_smooth{5} = imgaussfilt(imgcell_hsv3{patch_no},4);
I_smooth{6} = imgaussfilt(imgcell_hsv3{patch_no},8);

%edges image
for k=1:6
    I_e{k} = edge(I_smooth{k},'Sobel');
end

for k=1:6
    subplot(3,6,k); imshow(I_smooth{k});
    [Gmag_I_smooth,Gdir_smooth] = imgradient(I_smooth{k});
    Gmag{k} = Gmag_I_smooth;
    Gdir{k} = Gdir_smooth;
    subplot(3,6,k+6); imshow(Gmag{k}+0.3*imgcell_bw{patch_no});
    subplot(3,6,k+12); imshow(I_e{k}+0.3*imgcell_bw{patch_no});
    
    fou_I{k} = fft2(I_smooth{k});
    ifou_I{k} = ifft2(fou_I{k});
    %fou_I{k}(1,1) = 0;
    %imagesc(abs(fftshift(Y)))
end

% inverse fourier transform - get image in spatial domain back
[r,c] = size(fou_I{2});
w = window2(r,c,'gausswin');
%fou2 = fftshift(fou_I{2}).*(1-w);

fou2 = ifftshift(fou2);
ifou2 = ifft2(fou2);
imagesc(abs(ifou2));

figure('Name','Gradient');
for k = 1:6
    subplot(3,6,k); imshow(I_smooth{k});
    subplot(3,6,k+6); imagesc(Gmag{k});   % Gradient Magnitude
    subplot(3,6,k+12); imagesc(abs(fftshift(fou_I{k}))); % Gradient Direction
    
end


%{
test = abs(fftshift(fou_I{2}));
test =  window2(3,3,'gausswin');
test = 1-test;


[x,y]=size(w);
X=1:x;
Y=1:y;
[xx,yy]=meshgrid(Y,X);
i=im2double(w);
figure;mesh(xx,yy,i);
figure;imshow(i)

Y = imfilter(I_smooth{1},test);
Y = conv2(I_smooth{1},test);
imagesc(Y)

figure();
histogram((Gdir{3}),360)




figure();
THm90 = imbinarize(Gdir{3},-90); % more than -90 
THp90 = imbinarize(Gdir{3},90);
THp90 = 1-THp90;

result = THm90.*THp90;
result = result.*(1-imgcell_bw{patch_no});
imshow(result);
imshow((imgcell_bw{patch_no}))

%}
%{
figure();
Y = prctile(reshape(Gmag{5},1,[]),90); 
BW = imbinarize(Gmag{5},Y);
imagesc(Gmag{5}.*BW);

figure();
BWdir = imbinarize(abs(Gdir{3}),170);
imshow(BWdir)


imagesc(Gdir{2})
%}





%{


I_source = imgcell_hsv3{1};
[Gmag_I_source,Gdir1] = imgradient(I_source);
[Gmag_I_smooth,Gdir2] = imgradient(I_smooth);

I_source_e  = edge(I_source,'Sobel');
I_smooth_e  = edge(I_smooth,'Sobel');

imshowpair(I_source_e,I_smooth_e+imgcell_bw{1},'montage');

imshow(I_source_e)
imshowpair(Gmag_I_source+imgcell_bw{1},Gmag_I_smooth,'montage');

Br = impyramid(imgcell_hsv3{1},'reduce');
Bx = impyramid(imgcell_hsv3{1},'expand');
imshow(Bx);

%}