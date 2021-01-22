%% load cie
cie = loadCIEdata;
%% step 2
img = imread('CC_Iphone11.jpg');

imwrite(img,'Rcesized_img.jpg');


%% define RGB values for each patch 

cam_rgbs = readmatrix('RGBavgs.xlsx');



norm_cam_rgbs = cam_rgbs./255;

cam_gray = norm_cam_rgbs(:,19:24);

low2high_gray = fliplr(cam_gray);

%% load in given data 

load('munki_CC_XYZs_Labs.txt');
munki_XYZs = (munki_CC_XYZs_Labs(:,2:4))';
munki_labs = (munki_CC_XYZs_Labs (:,5:7))';

gray_Ys = fliplr(munki_XYZs (2,19:24))./100;


%% graph 

figure
hold on
plot(gray_Ys, low2high_gray (1,:),'r');
plot(gray_Ys, low2high_gray (2,:),'g');
plot(gray_Ys, low2high_gray (3,:),'b');

title 'Original Grayscale Y vlaues compared to RGBs'
xlabel 'Munki gray Ys'
ylabel 'Camera gray RGBs' 

r = 1;
g = 2;
b = 3;

%% a) fit low order polynomal functions between normalized camera gray RGBS and color munki gray Ys

cam_polys (r,:) = polyfit(low2high_gray(r,:), gray_Ys, 3);
cam_polys (g,:) = polyfit(low2high_gray (g,:), gray_Ys, 3);
cam_polys (b,:) = polyfit(low2high_gray (b,:), gray_Ys, 3);

%% b) use linearize function 
cam_RSs (r,:) = polyval (cam_polys (r,:), norm_cam_rgbs (r,:));
cam_RSs (g,:) = polyval (cam_polys (g,:), norm_cam_rgbs (g,:));
cam_RSs (b,:) = polyval (cam_polys (b,:), norm_cam_rgbs (b,:));

%% c) take out range value 
cam_RSs(cam_RSs<0) = 0;
cam_RSs(cam_RSs>1) = 1;
 
%% make linearized graph 

figure
plot (gray_Ys, fliplr(cam_RSs (1,19:24)),'r');
hold on 
plot (gray_Ys, fliplr(cam_RSs (2, 19:24)), 'g');
plot (gray_Ys, fliplr(cam_RSs (3, 19:24)), 'b');

title 'Original Grayscale Y vales compared to RGB value'
xlabel 'munki gray Y values' 
ylabel 'linearized camera gray RGB values (RSs)' 

%% visualizing the original camera RGBs
pix = reshape (norm_cam_rgbs', [6 4 3 ]);
pix = uint8 (pix*255);
pix = imrotate (pix, -90);
pix = flip (pix, 2);
figure;
image (pix);
title ('original camera RGBs');

%% visualize linearized camera RGBS 
pix = reshape (cam_RSs', [6 4 3]);
pix =  uint8 (pix*255);
pix = imrotate (pix, -90);
pix = flip (pix, 2);
figure;
image (pix);
title ('Linearized camera colorchecker patches RGBs');


%% derive a 3x3 matrix that estiamtes XYZ values from the RGB radiometric scalars 
cam_matrix3x3 = munki_XYZs * pinv(cam_RSs) 


%% estimate the ColorChecker XYZs from the linearized camera rgbs using% the 3x3 camera matrix
cam_XYZs = cam_matrix3x3 * cam_RSs

%%
XYZn_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50);
camlabs = XYZ2Lab2(cam_XYZs,XYZn_D50)
cam_dEab = deltaEab(munki_labs,camlabs)

print_extended_camera_model_error(munki_labs,camlabs,cam_dEab);

%% split the radiometric scalars (cam_RSs) into r,g,b vectors
RSrgbs = cam_RSs;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);
%% create vectors of these RSs with multiplicative terms to represent interactions and square terms to represent non-linearities in the RGB-to-XYZ relationship
RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs;RSrs.^2;  RSgs.^2; RSbs.^2;  ones(1,size(RSrgbs,2))]; 
    
   
%% find the extended (3x11) matrix that relates the RS and XYZ datasets
cam_matrix3x11 = munki_XYZs * pinv(RSrgbs_extd)
 
%% estimate XYZs from the RSs using the extended matrix and RS% representation
cam_XYZs = cam_matrix3x11 * RSrgbs_extd
%% XYZ to lab
XYZn_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50);
camlabs3x11 = XYZ2Lab2(cam_XYZs,XYZn_D50)
cam3x11_dEab = deltaEab(munki_labs,camlabs3x11)

print_extended_camera_model_error(munki_labs,camlabs3x11,cam3x11_dEab);


%% save the (extended) camera model for use in later projects
save('cam_model.mat', 'cam_polys', 'cam_matrix3x11');

%% 
% b) test that the camRGB2XYZ function works correctly
cam_XYZs = camRGB2XYZ('cam_model.mat', 'RGBavgs.xlsx')



%% visualize the munki-measured XYZs as an sRGB image
XYZn_D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);
munki_XYZs_D65 = catBradford(munki_XYZs, XYZn_D50, XYZn_D65); 
munki_XYZs_sRGBs = XYZ2sRGB(munki_XYZs_D65)
pix = reshape(munki_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90); pix = flipdim(pix,2); figure;
image(pix);
title('munki XYZs chromatically adapted and visualized in sRGB');


%% visualize the camera-estimated XYZs as an sRGB image
cam_XYZs_D65 = catBradford(cam_XYZs, XYZn_D50, XYZn_D65); 
cam_XYZs_sRGBs = XYZ2sRGB(cam_XYZs_D65)
pix = reshape(cam_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flipdim(pix,2);
figure;
image(pix);
title('estimated XYZs chromatically adapted and visualized in sRGB')
