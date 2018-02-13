function [ feaVec ] = extShape4( I_toext_bw )

% V4 - no resize image width, template matching
% remove edges smoothing
% I_toext_bw = patch_bw_POS{1};
% I_toext_bw = patch_bw_NEG{1};
%IMGRZ_WIDTH = 120;
IMGRZ_WIDTH = size(I_toext_bw,2);
inputIMG =  I_toext_bw;

%//////////////////////////////////////////////////////////////////////////
%inputIMG_shpA = I_toext_bw;
inputIMG_shpA = inputIMG;

%inputIMG_shpA = imresize(inputIMG_shpA,[NaN, IMGRZ_WIDTH]);

% Region Boundary
bdry_idx = bwboundaries(inputIMG_shpA,'noholes');
bdry_I = imbinarize(inputIMG_shpA.*0);
idx_x = bdry_idx{1,1}(:,1); %{1,1} means first structure element
idx_y = bdry_idx{1,1}(:,2);

for c = 1:length(idx_x)
    bdry_I(idx_x(c),idx_y(c)) = 1;
end

%(inverse projection)lowest edges(of perimeter) onto image bottom (x-axis)
% last element of low_rowedges always = 1 (no boundary in bdry_I)
rowVal = 0;
[nrows,ncols] = size(bdry_I);
%ncols = ncols-1;

low_edges(1:(IMGRZ_WIDTH-1)) = 0;
for c = 1:ncols
    rowVal = 0;
    for row = 1:nrows    
        if(bdry_I(row,c)==1)
            if(row>=rowVal)
                rowVal = row;
            end
        end        
    end       
    low_edges(c) = nrows-rowVal;
    rowVal = 0;
end

% generate 3 Matched filter template : type1
h30_t1 = IMGRZ_WIDTH * tand(30);
h37_t1 = IMGRZ_WIDTH * tand(37.5);
h45_t1 = IMGRZ_WIDTH * tand(45);

dstep30_t1 = h30_t1/IMGRZ_WIDTH;
dstep37_t1 = h37_t1/IMGRZ_WIDTH;
dstep45_t1 = h45_t1/IMGRZ_WIDTH;

seq30_t1(1:IMGRZ_WIDTH) = zeros;
seq37_t1(1:IMGRZ_WIDTH) = zeros;
seq45_t1(1:IMGRZ_WIDTH) = zeros;

for i =  1:IMGRZ_WIDTH
    seq30_t1(i) = h30_t1 - ((i-1)*dstep30_t1);
    seq37_t1(i) = h37_t1 - ((i-1)*dstep37_t1);
    seq45_t1(i) = h45_t1 - ((i-1)*dstep45_t1);
end

% normailized in [0,1] by consider both seq,low_edges
low_edges_norm_temp = low_edges - min(low_edges(:));
low_edges_norm = low_edges_norm_temp ./ max(low_edges_norm_temp(:));

seq30_t1_norm = seq30_t1 ./ max(low_edges_norm_temp(:));
seq37_t1_norm = seq37_t1 ./ max(low_edges_norm_temp(:));
seq45_t1_norm = seq45_t1 ./ max(low_edges_norm_temp(:));

% generate 3 Matched filter template : type2
width_type2 = floor(0.75 * IMGRZ_WIDTH);
width_type2_rest = IMGRZ_WIDTH-width_type2;
h30_t2 = width_type2 * tand(30);
h37_t2 = width_type2 * tand(37.5);
h45_t2 = width_type2 * tand(45);

h_rest = width_type2_rest * tand(75);

dstep30_t2 = h30_t2/width_type2;
dstep37_t2 = h37_t2/width_type2;
dstep45_t2 = h45_t2/width_type2;

dstep_rest = h_rest/width_type2_rest;

seq30_t2(1:IMGRZ_WIDTH) = zeros;
seq37_t2(1:IMGRZ_WIDTH) = zeros;
seq45_t2(1:IMGRZ_WIDTH) = zeros;


for i =  1:width_type2
    seq30_t2(i) = h30_t2 - ((i-1)*dstep30_t2);
    seq37_t2(i) = h37_t2 - ((i-1)*dstep37_t2);
    seq45_t2(i) = h45_t2 - ((i-1)*dstep45_t2);
end

for i = 1:width_type2_rest
    seq30_t2(i+width_type2) = ((i-1)*dstep_rest);
    seq37_t2(i+width_type2) = ((i-1)*dstep_rest);
    seq45_t2(i+width_type2) = ((i-1)*dstep_rest);
end

seq30_t2_norm = seq30_t2 ./ max(low_edges_norm_temp(:));
seq37_t2_norm = seq37_t2 ./ max(low_edges_norm_temp(:));
seq45_t2_norm = seq45_t2 ./ max(low_edges_norm_temp(:));


% /// convolution edges with matched filter template
% /// type1
cor30t1 = conv(low_edges_norm, fliplr(seq30_t1_norm));
cor37t1 = conv(low_edges_norm, fliplr(seq37_t1_norm));
cor45t1 = conv(low_edges_norm, fliplr(seq45_t1_norm));
% /// type2
cor30t2 = conv(low_edges_norm, fliplr(seq30_t2_norm));
cor37t2 = conv(low_edges_norm, fliplr(seq37_t2_norm));
cor45t2 = conv(low_edges_norm, fliplr(seq45_t2_norm));

cor30t1_norm = ((cor30t1 - min(cor30t1)) ./ max(cor30t1));
cor37t1_norm = ((cor37t1 - min(cor37t1)) ./ max(cor37t1));
cor45t1_norm = ((cor45t1 - min(cor45t1)) ./ max(cor45t1));

cor30t2_norm = ((cor30t2 - min(cor30t2)) ./ max(cor30t2));
cor37t2_norm = ((cor37t2 - min(cor37t2)) ./ max(cor37t2));
cor45t2_norm = ((cor45t2 - min(cor45t2)) ./ max(cor45t2));

% target response
tar30t1 = conv(seq30_t1_norm,fliplr(seq30_t1_norm));

%error
e45t1 = abs(triangle_window - cor30t1_norm);

% finding area of peak allign in center of convolution result
bankcell{1,:} = cor30t1;
bankcell{2,:} = cor37t1;
bankcell{3,:} = cor45t1;
bankcell{4,:} = cor30t2;
bankcell{5,:} = cor37t2;
bankcell{6,:} = cor45t2;

% feature vector = area of conv / patch width
feaVec(1) = sum(bankcell{1}) / binwidth;
feaVec(2) = sum(bankcell{2}) / binwidth;
feaVec(3) = sum(bankcell{3}) / binwidth;
feaVec(4) = sum(bankcell{4}) / binwidth;
feaVec(5) = sum(bankcell{5}) / binwidth;
feaVec(6) = sum(bankcell{6}) / binwidth;


%{
plot(cor30t1);
hold on;
plot(cor37t1);
plot(cor45t1);
plot(cor30t2);
plot(cor37t2);
plot(cor45t2);

legend('30t1','37t1','45t1','30t2','37t2','45t2')

plot(triangle_window);
hold on;
plot(cor30t1_norm);
plot(cor37t1_norm);
plot(cor45t1_norm);
plot(cor30t2_norm);
plot(cor37t2_norm);
plot(cor45t2_norm);

legend('target','30t1','37t1','45t1','30t2','37t2','45t2')
%}
end





