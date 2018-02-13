

wavelength = [2 16];
orientation = [0 45 90];

g = gabor(wavelength,orientation);


for p = 1:length(g)
    subplot(3,2,p);
    imshow(real(g(p).SpatialKernel),[]);
    lambda = g(p).Wavelength;
    theta  = g(p).Orientation;
    title(sprintf('Re[h(x,y)], \\lambda = %d, \\theta = %d',lambda,theta));
end

test = g(2).SpatialKernel;
imagesc(real(test));


outMag = imgaborfilt(I_smooth{1},g);

outSize = size(outMag);
outMag = reshape(outMag,[outSize(1:2),1,outSize(3)]);
figure, montage(outMag,'DisplayRange',[]);
title('Montage of gabor magnitude output images.');


%{
 Wavelength of sinusoid, specified as a numeric scalar or vector, in px/cycle.
 Orientation of filter in degrees, a numeric scalar in the range [0 180], 
 where the orientation is defined as the normal direction to the sinusoidal plane wave
%}
