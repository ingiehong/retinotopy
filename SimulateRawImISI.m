%This scripts simulates raw data based on L54 provided by Callaway lab
% Grace Hwang
% Origination 1/19/2018

dbstop if error
close all; clear all; 
cd('C:\Users\Ingie\Documents\imager_data\L54');
%fileStruct=dir('*grab*.mat');
%load(fileStruct(1).name);
%grabim = grab.img;
load('L54_000_001.mat'); %f1m struct appears with two cells
%revert to real image first
im_real=real(f1m{1});
figure; imagesc(im_real);
ana=load('L54_u000_001.analyzer', '-mat')
numIm = length(ana.syncInfo1.acqSyncs);
sizeIm=size(im_real) % returns image size %1870
tens=zeros(sizeIm(1),sizeIm(2), numIm); %rows=218, col=226 [row, col]
for i = 1:numIm
    tens(:,:,i)=im_real;        
end
%imagesc(squeeze(angle(tens(:,:,1))));
figure; imagesc(squeeze(tens(:,:,1)));
tens(100,:,1)=size(repmat(max(max(im_real)),sizeIm(1)),1);
%        for k= 1:sizeIm(2)% col
 