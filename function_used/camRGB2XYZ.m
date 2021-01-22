function cam_XYZs = camRGB2XYZ(cam_model,cam_RGBS)
    load(cam_model)
    %cam_rgbs = readmatrix(cam_RGBS);

   
    original_cam_rgbs = cam_RGBS./255;
    
    load('munki_CC_XYZs_Labs.txt');
    munki_XYZs = (munki_CC_XYZs_Labs(:,2:4))';
    munki_labs = (munki_CC_XYZs_Labs (:,5:7))';

    gray_Ys = fliplr(munki_XYZs (2,19:24))./100;
    
    r = 1;
    g = 2;
    b = 3;
    cam_RSs (r,:) = polyval (cam_polys (r,:), original_cam_rgbs (r,:));
    cam_RSs (g,:) = polyval (cam_polys (g,:),original_cam_rgbs (g,:));
    cam_RSs (b,:) = polyval (cam_polys (b,:), original_cam_rgbs (b,:));
    cam_RSs(cam_RSs<0) = 0;
    cam_RSs(cam_RSs>1) = 1;
    
    RSrgbs = cam_RSs;
    RSrs = RSrgbs(1,:);
    RSgs = RSrgbs(2,:);
    RSbs = RSrgbs(3,:);
    RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs;RSrs.^2;  RSgs.^2; RSbs.^2;  ones(1,size(RSrgbs,2))]; 
    
    %cam_matrix3x11 =  munki_XYZs * (pinv(RSrgbs_extd));
    
    
    cam_XYZs = cam_matrix3x11 * RSrgbs_extd;
   


end