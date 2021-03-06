function [I_clused_hsv3,I_clused_bw,ctrdVal,nfound] = ...
         kmeansSegment(IMG_DIR,IMG_NO,NO_REGION)

% 1
%Threshold intensity channel

%IMG_NO = 4;
END_TY = '.jpg';
%IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_resize1\';
IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),END_TY);

I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level);
I_hsv3_thresh_d = double(I_hsv3_thresh);
I_hsv3_thresh_d(I_hsv3_thresh_d == 0) = -1;

%figure('Name','Input Intensity Image - Thresholded Image');
%imshowpair(I_hsv3,I_hsv3_thresh,'montage');

I_mask1 = I_hsv3_thresh_d.*I_hsv1;  %Hue image && Foreground            
I_mask1(I_mask1 <= 0) = -1;

%warp back X(X>0.5) = 1-X
%I_mask1(I_mask1 >0.5) = 1-I_mask1;
for i = 1:size(I_mask1,1)
    for j = 1:size(I_mask1,2)
        if I_mask1(i,j) > 0.5
            I_mask1(i,j) = 1-I_mask1(i,j);
        end
    end
end

%K-means Color
NO_CLUS = 6; % number of color cluster
INI_CTND = [-1 0 0.2 0.3 0.4 0.5]'; %initial seed for kmeans
[nRows, nCols] = size(I_mask1);

I_kresult(nRows, nCols, NO_CLUS) = zeros;                % Kmeans Clustered
%I_k_binary(nRows, nCols, nClus) = zeros('logical');     % -
I_mask1_fmtd = reshape(I_mask1,nRows*nCols,1);
[clus_idx,ctrdVal] = kmeans(I_mask1_fmtd, NO_CLUS,'Start',INI_CTND);

pixel_labels = reshape(clus_idx,nRows,nCols);   %result image

for k = 1:NO_CLUS
    I_temp = I_kresult(:,:,k) + pixel_labels;
    I_temp(I_temp ~= k) = 0;
    I_kresult(:,:,k) = sign(I_temp);
    %I_k_binary(:,:,k) = imbinarize(I_kresult(:,:,k));
end


% ////////////////////////////////////////////////////////////////////////

% 2
%Intensity & Color Segmented
%Suppress Small dot by median filter
SELECT_CLUSTER = 2;

%Apply median filter : I_k_filt
I_k_filt = medfilt2(I_kresult(:,:,SELECT_CLUSTER), [3 3]);
I_ic = I_k_filt.*I_hsv3 ;

%imshowpair(I_kresult(:,:,SELECT_CLUSTER),I_k_filt,'montage');
%imshow(I_ic);

% Connected Component Labelling
% Pick n biggest area(mode) then create sq.bounding box
NO_REGION = NO_REGION+1;    % No. of Biggest area +1 include BG
mode_I_ic(NO_REGION) = zeros;
I_label_bin = I_ic * 0;
[I_label, nfound] = bwlabeln(I_ic);
I_ic_vector = reshape(I_label,1,[]);

vector_copy = I_ic_vector;
% 1st mode (Always background)
for i = 1:NO_REGION
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end

% Collect Selected mode
for i = 2:NO_REGION
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0;
    I_label_bin = I_label_bin + temp;
end
I_label_bin = imbinarize(I_label_bin);
stats_box = regionprops(I_label_bin,'BoundingBox');
%{
imshowpair(I_label_bin,I_label_hsv3,'montage');

% Bounding Box
figure('Name','Selected n-th large area');
imshow(I_label_bin.*I_hsv3);
hold on;
axis normal;
axis on;


for k = 1 : length(stats_box)
  BB = stats_box(k).BoundingBox;
  rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],...
  'EdgeColor','green','LineWidth',2 )
end
%}
I_clused_bw{length(stats_box),1} = []; %image patch storing cell
I_clused_hsv3{length(stats_box),1} = [];

for k = 1 : length(stats_box)
  BB = stats_box(k).BoundingBox;  
  I_toext = I_hsv3( ceil(BB(2)):(floor(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(floor(BB(1))+ceil(BB(3))));
  I_toext_bw = I_label_bin( ceil(BB(2)):(floor(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(floor(BB(1))+ceil(BB(3))));
  
  I_clused_hsv3{k,1} = I_toext;                  
  I_clused_bw{k,1} = I_toext_bw;
  
end

%{
figure();imshowpair(I_hsv3,I_mask1,'montage');

figure('Name','Kmeans Group');
imshow(pixel_labels,[]), title('image labeled by cluster index');

figure('Name','Output Cluster Image');
for k = 1:nClus
    subplot(1,nClus,k);
    imshow(I_k_binary(:,:,k));
    title(['Cluster',num2str(k)]); 
    xlabel(cen_Color(k));
end
%}

end

