function [t,magCal,magUncal,hardOS,softOS] = Mag_Calibration(platform)

% Get name of file file containing magnetometer data
% Assumed to be time/magx/magy/magz
% Can be .txt delimited with tab or .csv
filename = input('Input name of calibration data file inlcuding extension: ','s');

% Determine if file is .txt or .csv
isCSV = strfind(filename,'.csv');
isTxt = strfind(filename,'.txt');

% Read in file excluding 1 row of headers
if (isempty(isCSV) && isempty(isTxt))
    error('Invalid file type')
elseif (isempty(isCSV))
    magData = dlmread(filename,'\t',1,0);
elseif (isempty(isTxt))
    magData = csvread(filename,1,0);
end

% Break up data into individual vectors
t = magData(:,1);
if (platform == 'S' || platform == 's' || platform == 'G' || platform == 'g')
    rawMag_x(1,:) = magData(:,2);
    rawMag_y(1,:) = magData(:,3);
    rawMag_z(1,:) = magData(:,4);
else
    rawMag_x(1,:) = (53/2500).*magData(:,8);
    rawMag_y(1,:) = (53/2500).*magData(:,9);
    rawMag_z(1,:) = (53/2500).*magData(:,10);
end

% Matrix of all uncalibrated magnetometer data where each column is a 
% 3-axis measurement
magUncal = [rawMag_x;
            rawMag_y;
            rawMag_z];

% Find hard iron offsets
% ellipsoid_fit function by Yury Petrov, Oculus VR
% Found here: http://www.mathworks.com/matlabcentral/fileexchange/24693-ellipsoid-fit
% Calculates the best fit elliptoid for raw magnometer data and returns the
% parameters that define it.
% hardOS = hard iron offsets in x,y,and z
% radii = elliptoid radii
% evecs = eigenvectors
% v = components of the elliptoid equation
% chi2 = residual error
[hardOS, radii, evecs, v, chi2] = ellipsoid_fit(magUncal');

% Find soft iron offset matrix
softOS = Gauss_Newton_Mag(magUncal,hardOS,platform);

% Initialize calibrated data matrix
magCalTemp = zeros(3,size(magUncal,2));

% Populate calibrated data matrix
for i=1:size(magCalTemp,2)
    magCalTemp(:,i) = softOS*(magUncal(:,i)-hardOS);
end

magCal = magCalTemp;
end
%
%
%
%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%