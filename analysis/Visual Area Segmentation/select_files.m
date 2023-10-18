function fullfilename=select_files()
% GUI interface for selection of 1 or multiple files. 

[FileName PathName] = uigetfile('*.*','Select files','MultiSelect', 'on');

fullfilename=fullfile(PathName,FileName);
if ~iscell(fullfilename) 
    fullfilename={fullfilename};
end
