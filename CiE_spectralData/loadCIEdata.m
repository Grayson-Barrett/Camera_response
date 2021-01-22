function [cie] = loadCIEdata 
 lambda = readmatrix('CIE_2Deg_380-780-5nm.txt');
 CIE10Deg = readmatrix('CIE_10Deg_380-780-5nm.txt');
 CIEIllA = readmatrix('CIE_IllA_380-780-5nm.txt');
 CIEIllC = readmatrix('CIE_IllC_380-780-5nm.txt');
 CIEIllD50 = readmatrix('CIE_IllD50_380-780-5nm.txt');
 CIEIllD65 = readmatrix('CIE_IllD65_380-780-5nm.txt');
 CIEIllF = readmatrix('CIE_IllF_1-12_380-780-5nm.txt');
 
   cie.lambda = lambda(:,1); 
   cie.cmf2deg = lambda(1:81,2:4);
   cie.cmf10deg = CIE10Deg(1:81,2:4);
   cie.illA = CIEIllA(:,2);
   cie.illC = CIEIllC(:,2);
   cie.illD50 = CIEIllD50(:,2);
   cie.illD65 = CIEIllD65(:,2);
   cie.illE = ones(81,1)*100;
   cie.illF = CIEIllF(1:81,2:13);
   cie.PRD = ones(81,1);
end

   
   
   