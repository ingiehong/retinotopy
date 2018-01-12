function imgr_close

button = questdlg('Are you sure you want to exit the imager?')

if strcmp(button,'Yes')
    close('imager')
end
%     
    