% this script sets up the imager
cd('C:\Users\Ingie\Documents\My Code\Callaway_ISI\imager')
%to get access to Grasshopper3 
%Start Image Acquisition Toolbox

%https://www.mathworks.com/matlabcentral/answers/91834-how-do-i-calculate-the-packet-delay-for-a-gige-vision-camera-to-prevent-dropped-frames
%to get access to Dalsa
% vid = videoinput('gige', 1, 'Mono10'); %10 bit monochrome system
% src = getselectedsource(vid);
% preview(vid);
% stoppreview(vid);
% src.PacketSize = 1500;
% src.AcquisitionFrameRate = 3.332;
% src.ExposureTime = 100000;
% src.AcquisitionFrameRate = 9.994;
% src.ExposureTime = 99000;
% src.AcquisitionFrameRate = 10;
% vid.FramesPerTrigger = 10;
% stoppreview(vid);
% im = getdata(vid);
% implay(im);
% size(im)
% ans =
%         1024        1280           1          10
