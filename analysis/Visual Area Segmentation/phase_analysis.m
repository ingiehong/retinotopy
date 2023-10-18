function [phaseMap, powerMap, spectrumMovie] = phase_analysis(im) 
% 
% 
% Ingie Hong, Johns Hopkins Medical Institute, 2018
im = double(im);
im_zeroed = im - mean(im,3);
spectrumMovie = fft(im_zeroed, [], 3);
powerMovie = (abs(spectrumMovie) * 2.) / size(spectrumMovie, 3);
powerMap = abs(powerMovie(:,:,2));
phaseMovie = angle(spectrumMovie);
phaseMap = -1 * phaseMovie(:,:,2);
phaseMap = mod( phaseMap,  (2 * pi));

%%
% figure; 
% subplot(1,2,1)
% imagesc(phaseMap)
% axis image
% title('Phase map')
% subplot(1,2,2)
% imagesc(powerMap)
% axis image
% title('Power map')
