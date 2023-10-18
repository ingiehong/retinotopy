% Average, normalize, and filter multiple tif files with same dimensions, uint16
% Save as _norm_mean.tif, _norm_mean_filt.tif, and '_norm_mean_filt_dff.tif
%
% Ingie Hong, Johns Hopkins Medical Institute, 2018

norm_range_y = [1:50];
%norm_range_x = [480-49:480]; % 431:480  /OR/   1:50 for right top corner/right top corner  respectively
norm_range_x = 1:50;
%% Select tif files
tif_files = select_files;
clear im
figure
for j=1:size(tif_files,2)
   im(:,:,:,j) = loadtiff(tif_files{j});
   plot(squeeze(mean(mean(im(:,:,:,j),1),2))/mean(mean(mean(im(:,:,:,j),1),2),3))
   hold on
end
yl = ylim;
% Normalize video to corner 50x50 pixel patch
im_norm = double(im).*(repmat(mean(mean(im(norm_range_y, norm_range_x,1,:),1),2),300,480,183)) ./(repmat(mean(mean(im(norm_range_y, norm_range_x,:,:),1),2),300,480)); 

figure
for j=1:size(tif_files,2)
    plot(squeeze(mean(mean(im_norm(:,:,:,j),1),2))/mean(mean(mean(im_norm(:,:,:,j),1),2),3))
    hold on
end
title('Normalized averaged timeseries')
ylim(yl)

figure;imagesc(im(:,:,1,1))
axis image
title('Raw image')
rectangle('Position',[norm_range_x(1) norm_range_y(1)  norm_range_x(end)-norm_range_x(1) norm_range_y(end)-norm_range_y(1)])

figure;imagesc(var( single(im(:,:,:,1)), [] ,3 ))
%set(gca, 'Clim', get(gca, 'CLim')*[1 0 ; 0 0.2])
axis image
title('Variance over time')
rectangle('Position',[norm_range_x(1) norm_range_y(1)  50 50])


figure
for j=1:size(tif_files,2)
    [phaseMap, powerMap] = phase_analysis(im_norm(:,:,:,j));
    subplot(2,size(tif_files,2)+1,j)
    imagesc( imgaussfilt( phaseMap ,5)) 
    title(['Phase map for #' num2str(j) ])
    colormap(jet); axis image;
    colorbar('southoutside')
    subplot(2,size(tif_files,2)+1,size(tif_files,2)+1+j)
    imagesc( imgaussfilt( powerMap,5 )) 
    title(['Power map for #' num2str(j) ])
    colormap(jet); axis image;
    colorbar('southoutside')
end

%% Save tif file
if size(tif_files,2)>2 
    common_to_use = tif_files{1}(all(~diff(char(tif_files(:)))));
else
    common_to_use = tif_files{1}((~diff(char(tif_files(:)))));
end
[PathName,SharedFileName,~]  = fileparts(common_to_use);
options.overwrite = true;
im_norm=mean(im_norm,4);

subplot(2,size(tif_files,2)+1,size(tif_files,2)+1)
imagesc( imgaussfilt( phase_analysis(im_norm),5) )
title(['Average phase map' ])
colormap(jet); axis image;
%set(gca, 'Clim', [ 0 2*pi])
colorbar('southoutside')

%saveastiff(uint16(mean(im,4)),common_to_use )
saveastiff(uint16( im_norm ),[PathName filesep SharedFileName '_norm_mean.tif'], options )
disp(['Normalized & averaged tif file saved as: ' PathName filesep SharedFileName '_norm_mean.tif'])

figure
plot(squeeze(mean(mean(im_norm(:,:,:),1),2))/mean(im_norm(:)))
hold on
im_norm = imgaussfilt3(im_norm,[ 0.1 0.1 5]);
plot(squeeze(mean(mean(im_norm(:,:,:),1),2))/mean(im_norm(:)))
title('Filtered & normalized averaged timeseries')
ylim(yl)

saveastiff(uint16( im_norm ),[PathName filesep SharedFileName '_norm_mean_filt.tif'], options )
disp(['Filtered & normalized & averaged tif file saved as: ' PathName filesep SharedFileName '_norm_mean_filt.tif'])

% Normalize video to df/F
im_dff = double(im_norm)./(repmat(mean(im_norm,3),1,1,183,1)); 
im_dff = imgaussfilt3(im_dff,[ 0.1 0.1 5]);
im_dff_uint16=uint16(   ( (2^15)/(max(im_dff(:))-min(im_dff(:))))  *   (im_dff - min(im_dff(:)))  );   % Normalize to uint16 range
saveastiff(uint16(mean(im_dff_uint16,4)),[PathName filesep SharedFileName '_norm_mean_filt_dff.tif'], options )
disp(['DFF & filtered & normalized & averaged tif file saved as: ' PathName filesep SharedFileName '_norm_mean_filt_dff.tif'])
