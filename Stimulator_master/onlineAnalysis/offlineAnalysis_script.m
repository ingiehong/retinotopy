

%% Load analyzer
[ fName, pathname ]= uigetfile('*.analyzer', 'Select an analyzer file', 'C:\Users\Huganir lab\Documents\imager_data\');
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName),'-mat');
end

dataPath= pathname;
%load('180705_u000_000.analyzer', '-mat')

[ fName, pathname ]= uigetfile('*.mat', 'Select 1st image data MATLAB file', dataPath);
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

[~,name,~] = fileparts(fName);
%load('180705_u000_000_001.mat')
im=squeeze(im);

offlineAnalysis(1,syncInfo1, im, [pathname, name, '.tif'] )


[ fName, pathname ]= uigetfile('*.mat', 'Select 2nd image data MATLAB file', dataPath);
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

[~,name,~] = fileparts(fName);
%load('180705_u000_000_001.mat')
im=squeeze(im);

offlineAnalysis(2,syncInfo1, im, [pathname, name, '.tif'] )
