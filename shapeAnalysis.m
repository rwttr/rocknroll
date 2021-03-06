%{
NO_FILE = 102;
IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
IMGPATH_POS_BW = 'patch_nexus_600x800_L1\POS_bw\';
IMGPATH_POS_HSV3 = 'patch_nexus_600x800_L1\POS_hsv3\';
IMGPATH_NEG_BW = 'patch_nexus_600x800_L1\NEG_bw\';
IMGPATH_NEG_HSV3 = 'patch_nexus_600x800_L1\NEG_hsv3\';

pos_bw_store{NO_FILE,1} = [];
pos_hsv3_store{NO_FILE,1} = [];

neg_bw_store{NO_FILE*4,1} = [];
neg_hsv3_store{NO_FILE*4,1} = [];


j=1;
for i= 1:NO_FILE
    
    % Load positive patches
    img_dir_pos_bw = strcat(IMGPATH_POS_BW,'patch_bw_POS_',int2str(i),'.mat');
    img_dir_pos_hsv3 = strcat(IMGPATH_POS_HSV3,'patch_hsv3_POS_',int2str(i),'.mat');
    pos_bw_store{i,1} = load(img_dir_pos_bw);
    pos_hsv3_store{i,1} = load(img_dir_pos_hsv3);
    imgcell_pos_bw{i,1} = pos_bw_store{i,1}.patch_bw_POS{1,1};
    imgcell_pos_hsv3{i,1} = pos_hsv3_store{i,1}.patch_hsv3_POS{1,1};
    imgcell_pos_bw{i,2} = pos_bw_store{i,1}.patch_bw_POS{1,2};
    imgcell_pos_hsv3{i,2} = pos_hsv3_store{i,1}.patch_hsv3_POS{1,2};
    
    % Load negative patches
    img_dir_neg_bw = strcat(IMGPATH_NEG_BW,'patch_bw_NEG_',int2str(i),'.mat');
    img_dir_neg_hsv3 = strcat(IMGPATH_NEG_HSV3,'patch_hsv3_NEG_',int2str(i),'.mat');
    neg_bw_store{i,1} = load(img_dir_neg_bw);       
    neg_hsv3_store{i,1} = load(img_dir_neg_hsv3);
    %{
    %load original image       
    IMGPATH = strcat(IMG_DIR,int2str(i),'.jpg');
    I_rgb = imread(IMGPATH);
    I_hsv = rgb2hsv(I_rgb);
    I_hsv3 = I_hsv(:,:,3); % Value
    imgcell_pos{i,1} = I_hsv3;
    %}

    imgcell_neg_hsv3{j} = neg_hsv3_store{i,1}.patch_hsv3_NEG{1,1};
    imgcell_neg_hsv3{j+1} = neg_hsv3_store{i,1}.patch_hsv3_NEG{2,1};
    imgcell_neg_hsv3{j+2} = neg_hsv3_store{i,1}.patch_hsv3_NEG{3,1};
    imgcell_neg_hsv3{j+3} = neg_hsv3_store{i,1}.patch_hsv3_NEG{4,1};

    imgcell_neg_bw{j} = neg_bw_store{i,1}.patch_bw_NEG{1,1};
    imgcell_neg_bw{j+1} = neg_bw_store{i,1}.patch_bw_NEG{2,1};
    imgcell_neg_bw{j+2} = neg_bw_store{i,1}.patch_bw_NEG{3,1};
    imgcell_neg_bw{j+3} = neg_bw_store{i,1}.patch_bw_NEG{4,1};
    
    j = j+4;
end
%}



%{

for patch_no = 1:102
%patch_no = 1;
%show segmantation result
result_bw = imgcell_pos_bw{patch_no,2};
result_bw_bb = imgcell_pos_bw{patch_no,2};

for j = 1:4 %each neg patch
    result_bw_bb = result_bw_bb + (j+1).*neg_bw_store{patch_no}.patch_bw_NEG{j,2};
    result_bw = result_bw + neg_bw_store{patch_no}.patch_bw_NEG{j,2};
end
fig0 =figure();
imshow(result_bw); truesize;
fig1 =figure();
imshow(result_bw_bb); truesize;
hold on;
st = regionprops(result_bw_bb,'BoundingBox');
for k = 1 : length(st)
  thisBB = st(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','y','LineWidth',1.25 )
end
hold off;

% Bounding Box on Intensity image
fig1_1 = figure();
imshow(imgcell_pos{patch_no}); truesize;
hold on;
for k = 1 : length(st)
  thisBB = st(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','y','LineWidth',1.25 )
end
hold off;

% Bottom edges extraction
%--------------------------------------------------------------------------
[ ~, le_pos ] = extShape4( imgcell_pos_bw{patch_no,1} );
[ ~, le_neg1 ] = extShape4( neg_bw_store{patch_no}.patch_bw_NEG{1,1} );
[ ~, le_neg2 ] = extShape4( neg_bw_store{patch_no}.patch_bw_NEG{2,1} );
[ ~, le_neg3 ] = extShape4( neg_bw_store{patch_no}.patch_bw_NEG{3,1} );
[ ~, le_neg4 ] = extShape4( neg_bw_store{patch_no}.patch_bw_NEG{4,1} );

fig2 = figure();
plot(le_pos,'LineWidth',0.75); hold on;
plot(le_neg1,'LineWidth',0.75);
plot(le_neg2,'LineWidth',0.75);
plot(le_neg3,'LineWidth',0.75);
plot(le_neg4,'LineWidth',0.75);
title('Edges plot')
legend('true tapped edges');
xlabel('Width (pixels)') % x-axis label
ylabel('Distance : bounding box to image area (pixels)') % y-axis label
hold off;

le_pos_smoothed = movmean(le_pos,3);
fig3 = figure();
plot(le_pos_smoothed,'LineWidth',0.75); hold on;
plot(movmean(le_neg1,3),'LineWidth',0.75);
plot(movmean(le_neg2,3),'LineWidth',0.75);
plot(movmean(le_neg3,3),'LineWidth',0.75);
plot(movmean(le_neg4,3),'LineWidth',0.75);
title('Smoothed edges plot')
legend('true tapped edges');
xlabel('Width (pixels)') % x-axis label
ylabel('Distance : bounding box to image area (pixels)') % y-axis label
hold off;

% Each patches
fig4 = figure();
subplot(1,5,1); 
    imshowpair(imgcell_pos_bw{patch_no,1},...
        imgcell_pos_hsv3{patch_no,1},'montage');
subplot(1,5,2);
    imshowpair(neg_bw_store{patch_no}.patch_bw_NEG{1,1},...
        neg_hsv3_store{patch_no}.patch_hsv3_NEG{1,1},'montage');
subplot(1,5,3);
    imshowpair(neg_bw_store{patch_no}.patch_bw_NEG{2,1},...
        neg_hsv3_store{patch_no}.patch_hsv3_NEG{2,1},'montage');
subplot(1,5,4);
    imshowpair(neg_bw_store{patch_no}.patch_bw_NEG{3,1},...
        neg_hsv3_store{patch_no}.patch_hsv3_NEG{3,1},'montage');
subplot(1,5,5);
    imshowpair(neg_bw_store{patch_no}.patch_bw_NEG{4,1},...
        neg_hsv3_store{patch_no}.patch_hsv3_NEG{4,1},'montage');
set(fig4, 'Position', [100, 100, 1200, 300]);


% Frequency analysis
%--------------------------------------------------------------------------
Ip = imgcell_pos_bw{patch_no,1};
In1 =  neg_bw_store{patch_no}.patch_bw_NEG{1,1} ;
In2 =  neg_bw_store{patch_no}.patch_bw_NEG{2,1} ;
In3 =  neg_bw_store{patch_no}.patch_bw_NEG{3,1} ;
In4 =  neg_bw_store{patch_no}.patch_bw_NEG{4,1} ;

% simple gaussian filter
hd = fspecial('gaussian',7,1);
hd = hd ./ max(hd(:));
gauss_lpf = fsamp2(hd);
gauss_hpf = fsamp2(1-hd); %hpf
%figure(); freqz2(gauss_lpf);
%figure(); freqz2(gauss_hpf);

% Laplacian Filter
h_lap = fspecial('laplacian',0.5);
%freqz2(h_lap);

% Laplacian (hpf) og Gaussian (lpf)
h_log = fspecial('log',[7 7],1);
%freqz2(h_log);

% Gaussian LPF
Ip_lp = filter2(gauss_lpf,imgcell_pos_hsv3{patch_no,1});
In1_lp = filter2(gauss_lpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{1,1});
In2_lp = filter2(gauss_lpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{2,1});
In3_lp = filter2(gauss_lpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{3,1});
In4_lp = filter2(gauss_lpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{4,1});
% Gaussian HPF
Ip_hp = filter2(gauss_hpf,imgcell_pos_hsv3{patch_no,1});
In1_hp = filter2(gauss_hpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{1,1});
In2_hp = filter2(gauss_hpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{2,1});
In3_hp = filter2(gauss_hpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{3,1});
In4_hp = filter2(gauss_hpf,neg_hsv3_store{patch_no}.patch_hsv3_NEG{4,1}); 
% Laplacian
Ip_lap = filter2(h_lap,imgcell_pos_hsv3{patch_no,1});
In1_lap = filter2(h_lap,neg_hsv3_store{patch_no}.patch_hsv3_NEG{1,1});
In2_lap = filter2(h_lap,neg_hsv3_store{patch_no}.patch_hsv3_NEG{2,1});
In3_lap = filter2(h_lap,neg_hsv3_store{patch_no}.patch_hsv3_NEG{3,1});
In4_lap = filter2(h_lap,neg_hsv3_store{patch_no}.patch_hsv3_NEG{4,1});
% LoG
Ip_log = filter2(h_log,imgcell_pos_hsv3{patch_no,1});
In1_log = filter2(h_log,neg_hsv3_store{patch_no}.patch_hsv3_NEG{1,1});
In2_log = filter2(h_log,neg_hsv3_store{patch_no}.patch_hsv3_NEG{2,1});
In3_log = filter2(h_log,neg_hsv3_store{patch_no}.patch_hsv3_NEG{3,1});
In4_log = filter2(h_log,neg_hsv3_store{patch_no}.patch_hsv3_NEG{4,1});

% Gaussian LPF
%--------------------------------------------------------------------------
fig5 = figure('Name','Gaussian LPF'); 
top = max(max(Ip_lp));
bot = min(min(Ip_lp));
subplot(2,5,1); imagesc(Ip_lp); title('Gaussian LPF'); caxis([bot top]);caxis manual
subplot(2,5,2); imagesc(In1_lp);caxis([bot top]);
subplot(2,5,3); imagesc(In2_lp);caxis([bot top]);
subplot(2,5,4); imagesc(In3_lp);caxis([bot top]);
subplot(2,5,5); imagesc(In4_lp);caxis([bot top]);
subplot(2,5,6); imagesc(Ip_lp.*Ip); 
    title('Gauss-LPF x Mask');
    [mag] = avgGradDir(Ip_lp,Ip);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([0 top]);
subplot(2,5,7); 
    imagesc(In1_lp.*In1);
    [mag] = avgGradDir(In1_lp,In1);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,8); 
    imagesc(In2_lp.*In2);
    [mag] = avgGradDir(In2_lp,In2);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,9); 
    imagesc(In3_lp.*In3);
    [mag] = avgGradDir(In3_lp,In3);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,10); 
    imagesc(In4_lp.*In4);
    [mag] = avgGradDir(In4_lp,In4);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
colormap gray;
colorbar('location','Manual', 'position', [0.93 0.1 0.02 0.81]);
set(fig5, 'Position', [100, 100, 1200, 900]);

% Gaussian HPF
%--------------------------------------------------------------------------
fig6 = figure('Name','Gaussian HPF'); 
top = max(max(Ip_hp));
bot = min(min(Ip_hp));
subplot(2,5,1); imagesc(Ip_hp); title('Gaussian HPF'); caxis([bot top]);
subplot(2,5,2); imagesc(In1_hp);caxis([bot top]);
subplot(2,5,3); imagesc(In2_hp);caxis([bot top]);
subplot(2,5,4); imagesc(In3_hp);caxis([bot top]);
subplot(2,5,5); imagesc(In4_hp);caxis([bot top]);
subplot(2,5,6); imagesc(Ip_hp.*Ip); 
    title('Gauss-HPF x Mask'); 
    [mag] = avgGradDir( Ip_hp,Ip );
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,7); 
    imagesc(In1_hp.*In1);
    [mag] = avgGradDir(In1_hp,In1);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,8); 
    imagesc(In2_hp.*In2);
    [mag] = avgGradDir(In1_hp,In1);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,9); 
    imagesc(In3_hp.*In3);
    [mag] = avgGradDir(In1_hp,In1);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,10); 
    imagesc(In4_hp.*In4);
    [mag] = avgGradDir(In4_hp,In4);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
colormap gray;
colorbar('location','Manual', 'position', [0.93 0.1 0.02 0.81]);
set(fig6, 'Position', [100, 100, 1200, 900]);

% Laplacian
%--------------------------------------------------------------------------
fig7 = figure('Name','Laplacian HPF');
top = max(max(Ip_lap));
bot = min(min(Ip_lap));
subplot(2,5,1); imagesc(Ip_lap); title('Laplacian HPF');caxis([bot top]);
subplot(2,5,2); imagesc(In1_lap);caxis([bot top]);
subplot(2,5,3); imagesc(In2_lap);caxis([bot top]);
subplot(2,5,4); imagesc(In3_lap);caxis([bot top]);
subplot(2,5,5); imagesc(In4_lap);caxis([bot top]);
subplot(2,5,6); 
    imagesc(Ip_lap.*Ip); 
    title('Laplacian x Mask');
    [mag] = avgGradDir(Ip_lap,Ip);
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,7); 
    imagesc(In1_lap.*In1);
    [mag] = avgGradDir(In1_lap,In1);
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,8); 
    imagesc(In2_lap.*In2);
    [mag] = avgGradDir(In2_lap,In2);
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,9);  
    imagesc(In3_lap.*In3);
    [mag] = avgGradDir(In3_lap,In3);
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,10); 
    imagesc(In4_lap.*In4);
    [mag] = avgGradDir(In4_lap,In4);
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
colormap gray;
colorbar('location','Manual', 'position', [0.93 0.1 0.02 0.81]);
set(fig7, 'Position', [100, 100, 1200, 900]);

% LoG
% -------------------------------------------------------------------------
fig8 = figure('Name','LoG');
top = max(max(Ip_log));
bot = min(min(Ip_log));
subplot(2,5,1); imagesc(Ip_log);    title('LoG');    caxis([bot top]);    
subplot(2,5,2); imagesc(In1_log);   caxis([bot top]);
subplot(2,5,3); imagesc(In2_log);   caxis([bot top]);
subplot(2,5,4); imagesc(In3_log);   caxis([bot top]);
subplot(2,5,5); imagesc(In4_log);   caxis([bot top]);
subplot(2,5,6); 
    imagesc(Ip_log.*Ip); 
    title('LoG x Mask');
    [mag] = avgGradDir( Ip_log,Ip );
    xlabel(['Av: ', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,7); 
    imagesc(In1_log.*In1);
    [mag] = avgGradDir( In1_log,In1 );
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,8); 
    imagesc(In2_log.*In2);
    [mag] = avgGradDir( In2_log,In2 );
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,9); 
    imagesc(In3_log.*In3);
    [mag] = avgGradDir( In3_log,In3 );
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
subplot(2,5,10);
    imagesc(In4_log.*In4);
    [mag] = avgGradDir( In4_log,In4 );
    xlabel(['', num2str(mean(mag))]);
    caxis([bot top]);
colormap gray;
colorbar('location','Manual', 'position', [0.93 0.1 0.02 0.81]);
set(fig8, 'Position', [100, 100, 1200, 800]);
%--------------------------------------------------------------------------

% save into image file
%--------------------------------------------------------------------------
dir_all_bw = 'C:\Users\Rattachai\Desktop\ShpAna\all_bw';
dir_all_bw_bb = 'C:\Users\Rattachai\Desktop\ShpAna\all_bw_bb';
dir_le_plot = 'C:\Users\Rattachai\Desktop\ShpAna\le_plot';
dir_le_plot_smooth = 'C:\Users\Rattachai\Desktop\ShpAna\le_plot_smooth';
dir_all_patches = 'C:\Users\Rattachai\Desktop\ShpAna\all_patches';
dir_all_hsv3_bb = 'C:\Users\Rattachai\Desktop\ShpAna\all_hsv3_bb';

dir_gaussLP = 'C:\Users\Rattachai\Desktop\ShpAna\freq_GaussianLPF';
dir_gaussHP = 'C:\Users\Rattachai\Desktop\ShpAna\freq_GaussianHPF';
dir_lap = 'C:\Users\Rattachai\Desktop\ShpAna\freq_Laplacian';
dir_log = 'C:\Users\Rattachai\Desktop\ShpAna\freq_LoG';
fname = int2str(patch_no);

saveas(fig0, fullfile(dir_all_bw, fname), 'png');
saveas(fig1, fullfile(dir_all_bw_bb, fname), 'png');
saveas(fig1_1, fullfile(dir_all_hsv3_bb, fname), 'png');
saveas(fig2, fullfile(dir_le_plot, fname), 'png');
saveas(fig3, fullfile(dir_le_plot_smooth, fname), 'png');
saveas(fig4, fullfile(dir_all_patches, fname), 'png');

saveas(fig5, fullfile(dir_gaussLP, fname), 'png');
saveas(fig6, fullfile(dir_gaussHP, fname), 'png');
saveas(fig7, fullfile(dir_lap, fname), 'png');
saveas(fig8, fullfile(dir_log, fname), 'png');

close all
end

%}

%{
% plot of all positive low edges
%--------------------------------------------------------------------------
[ ~, le_pos ] = extShape3( imgcell_pos_bw{1,1},3,3 );
plot(movmean(le_pos,3)); hold on;
for patch_no = 1:102
    [ ~, le_pos ] = extShape3( imgcell_pos_bw{patch_no,1}, 3 , 3 );
    plot(movmean(le_pos,3));
end
title('all positive patchs measured distances plot')
xlabel('Width (pixels)') % x-axis label
ylabel('Measured Distance (pixels)');
grid on
daspect([0.5 1 1])

% plot all positive low_edges (same length)
%--------------------------------------------------------------------------
[ ~, le_edges ] = extShape2( imgcell_pos_bw{1,1}, 6, 3);
plot(le_edges); hold on;
for patch_no = 2:102
[ ~, le_edges ] = extShape2( imgcell_pos_bw{patch_no,1}, 6, 3);
plot(le_edges);
end
title('all positive smoothed edges plot (resample to equalize the length)')
xlabel('Width (pixels)') % x-axis label
ylabel('Distance : bottom of bounding box to image area (pixels)');

%all edges plot trim (same length)
%--------------------------------------------------------------------------
[ le_edges, ~ ] = extShape2( imgcell_pos_bw{1,1}, 3, 3);
plot(le_edges); hold on;
for patch_no = 2:102
[ le_edges, ~ ] = extShape2( imgcell_pos_bw{patch_no,1}, 3, 3);
plot(le_edges);
end
title('all positive smoothed edges plot (resample to equalize the length)')
xlabel('Width (pixels)') % x-axis label
ylabel('Distance : bottom of bounding box to image area (pixels)');


% all edges plot trim (each length)
%--------------------------------------------------------------------------
[ ~, le_edges ] = extShape3( imgcell_pos_bw{1,1}, 3, 3);
plot(le_edges); hold on;
for patch_no = 2:20
[ ~, le_edges ] = extShape3( imgcell_pos_bw{patch_no,1}, 3, 3);
plot(le_edges);
end
title('all positive smoothed edges plot (side trimmed)')
xlabel('Width (pixels)') % x-axis label
ylabel('Distance : bottom of bounding box to image area (pixels)');
%}

% output all patched from gabor filter bank

% 

WAVELENGTH = [8 12 16 24 32];
ORIENTATION = [0 30 45 75 90];

gBank = gabor(WAVELENGTH,ORIENTATION);

outMag = imgaborfilt(imgcell_pos_hsv3{80,1},gBank);


%spatial domain plot
subplot(1,3,1); mesh(real(gBank(1,1).SpatialKernel));
subplot(1,3,2); mesh(real(gBank(1,2).SpatialKernel));
subplot(1,3,3); mesh(real(gBank(1,3).SpatialKernel));

% Gabor filter Frequency Response 
%--------------------------------------------------------------------------
for i=1:length(gBank)
   subplot(5,length(gBank),i); freqz2(gBank(i).SpatialKernel);
   title([num2str(gBank(i).Wavelength) 'px/cycle, ' num2str(gBank(i).Orientation) 'degrees']);
   %daspect([1 1 1]);
end
set(gcf, 'Position', [100, 100, 1800, 1250]);



dir_gabor = 'C:\Users\Rattachai\Desktop\ShpAna\gabor_mag';

for img_no =80
Ip = imgcell_pos_bw{img_no,1};
%outMag = imgaborfilt(imgcell_pos_hsv3{img_no,1},gBank);
outMag = imgaborfilt(imgcell_neg_hsv3{320},gBank);
for i = 1:25
subplot(5,5,i); imagesc(outMag(:,:,i).*Ip); daspect([0.5 1 1]); %caxis([0 100]); 
title([num2str(gBank(i).Wavelength) ' px/cycle, ' num2str(gBank(i).Orientation) ' degrees']);
end
set(gcf, 'Position', [100, 100, 1250, 3000]);
fname = int2str(img_no);
saveas(gcf, fullfile(dir_gabor, fname), 'png');
end


dir_gabor = 'C:\Users\Rattachai\Desktop\ShpAna\gabor_mag\NEG';

for img_no =1:408
In = imgcell_neg_bw{img_no};
outMag = imgaborfilt(imgcell_neg_hsv3{img_no},gBank);
for i = 1:25
subplot(5,5,i); imagesc(outMag(:,:,i).*In); %caxis([0 100]);
title([num2str(gBank(i).Wavelength) ' px/cycle, ' num2str(gBank(i).Orientation) ' degrees']);
end
set(gcf, 'Position', [100, 100, 1250, 3000]);
fname = int2str(img_no);
saveas(gcf, fullfile(dir_gabor, fname), 'png');
end


for i = 1:10
    subplot(2,5,i); imshow(imgcell_pos_bw{i,1});
end

% Sample  image 80
%{
[ ~, le ] = extShape3( imgcell_neg_bw{80}, 6, 3 );
[ ~, le1 ] = extShape3( imgcell_neg_bw{320}, 6, 3 );
[ ~, le2 ] = extShape3( imgcell_neg_bw{321}, 6, 3 );
[ ~, le3 ] = extShape3( imgcell_neg_bw{322}, 6, 3 );
[ ~, le4 ] = extShape3( imgcell_neg_bw{323}, 6, 3 );

plot(le); hold on;
plot(movmean(le,3));
%plot(le1);
%plot(le2);
%plot(le3);
%plot(le4);
legend('Measure line','Smoothed line');
ylabel('Measured Distance (pixels)');
grid on
daspect([1 1 1])


% 5bin
binwidth = floor(length(le) / 5);
le_smooth = movmean(le,3);
le_trim = le_smooth(binwidth:end-binwidth);
le_bin2 = le_trim(1:binwidth);
le_bin3 = le_trim( (binwidth) : (2*binwidth));
le_bin4 = le_trim( end-binwidth : end);

le_bin2_diff = diff(le_bin2);
le_bin3_diff = diff(le_bin3);
le_bin4_diff = diff(le_bin4);

mp2 = sum(le_bin2_diff(le_bin2_diff>0))/binwidth;
mp3 = sum(le_bin3_diff(le_bin3_diff>0))/binwidth;
mp4 = sum(le_bin4_diff(le_bin4_diff>0))/binwidth;

mn2 = sum(le_bin2_diff(le_bin2_diff<0))/binwidth;
mn3 = sum(le_bin3_diff(le_bin3_diff<0))/binwidth;
mn4 = sum(le_bin4_diff(le_bin4_diff<0))/binwidth;

subplot(1,3,1); plot(le_bin2); daspect([1 1 1]); grid on
title('bin2');
xlabel({['average: ' num2str(mean(le_bin2))];...
    ['avg of diff+ : ' num2str(mp2)];['avg of diff- : ' num2str(mn2)]});


subplot(1,3,2); plot(le_bin3); daspect([1 1 1]); grid on
title('bin3');
xlabel({['average: ' num2str(mean(le_bin3))];...
    ['avg of diff+ : ' num2str(mp3)];['avg of diff- : ' num2str(mn3)]});

subplot(1,3,3); plot(le_bin4); daspect([1 1 1]); grid on
title('bin4');
xlabel({['average: ' num2str(mean(le_bin4))];...
    ['avg of diff+ : ' num2str(mp4)];['avg of diff- : ' num2str(mn4)]});

subplot(1,4,1); plot(le1); daspect([1 1 1]); grid on; title('neg1');
subplot(1,4,2); plot(le2); daspect([1 1 1]); grid on; title('neg2');
subplot(1,4,3); plot(le3); daspect([1 1 1]); grid on; title('neg3');
subplot(1,4,4); plot(le4); daspect([1 1 1]); grid on; title('neg4');

ylabel('Measured Distance (pixels)');
grid on
title('Trimmed Line');
daspect([1 1 1])
%}

subplot(1,2,1); imshow(imgcell_pos_bw{80});
subplot(1,2,2); imshow(imgcell_pos_hsv3{80});




