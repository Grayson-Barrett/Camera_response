CCcam = imread('CC_Iphone11.jpg');
red_ch = CCcam(:,:,1);
green_ch = CCcam(:,:,2);
blue_ch = CCcam(:,:,3);

imtool(CCcam);

dskin_roi = ([48.5894027335707 59.9906804827195 148.596423890657 100.291084854995]);
dskin = imcrop(CCcam,dskin_roi);
dskin_mean = mean(dskin,[1,2]);
dskin_rgb = reshape(dskin_mean,3,1);

lskin_roi = [238.704081632653 68.2755102040817 132.041378019098 89.1177102419915];
lskin_cp = imcrop(CCcam,lskin_roi);
lskin_mean = mean(lskin_cp,[1,2]);
lskin_rgb = reshape(lskin_mean,3,1);

RGB = [dskin_rgb, lskin_rgb];
