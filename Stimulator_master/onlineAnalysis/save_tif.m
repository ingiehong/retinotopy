function save_tif(imageStack, outputFileName)
% Write single channel or multi-channel tiff file
%
% imageStack is single channel 3D (ndim=3) or multi-channel 3D (ndim=5)
% image with channels as the 5th dimension (4th singleton)
%
% Ingie Hong, Johns Hopkins Medical Institute, 2015

if nargin < 1
    error('Requires imageStack input')
end

if nargin < 2
    outputFileName = 'img_stack.tif';
end

if ~exist('info','var')
    info(1).ImageDescription=' ';
end

[s1,s2,s3,s4,s5]=size(imageStack);

if s5==1
    % Single channel 3D images
    imwrite(imageStack(:, :, 1), outputFileName, 'WriteMode', 'append',  'Compression','none','Description', info(1).ImageDescription );
    for k=2:size(imageStack, 3)
       imwrite(imageStack(:, :, k), outputFileName, 'WriteMode', 'append',  'Compression','none' );
    end
    
else
    % Multiple channel 3D images
    imageStack = reshape( permute(imageStack, [1 2 5 3 4]), s1, s2, [] ); % 
    info(1).ImageDescription=['ImageJ=1.50g' char(10) 'images=' num2str(s3*s5) char(10) 'channels=' num2str(s5) char(10) 'slices=' num2str(s3) char(10) 'hyperstack=true' char(10) 'mode=color' char(10) 'loop=false' char(10)];
    imwrite(imageStack(:, :, 1), outputFileName, 'WriteMode', 'append',  'Compression','none','Description', info(1).ImageDescription );
    for k=2:size(imageStack, 3)
       imwrite(imageStack(:, :, k), outputFileName, 'WriteMode', 'append',  'Compression','none' );
    end
end
