
%IMG_NO = 44;
IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';

SAVE_DIR = 'C:\Users\Rattachai\Desktop\ShpAna2\segMix_gabor162024_color_le_Vote_singleROI_gabor55_zeroTH';




for img_no = 1:102
[I_ksegment] = kmeansSeg2(img_no,IMG_DIR);    
fig1 = figure();
imshow(I_ksegment); truesize;
fname = int2str(img_no);
saveas(fig1, fullfile(SAVE_DIR, fname), 'png');
close all
end