%This scripts load analyzer file and extracts grating information
%
% Grace Hwang
dbstop if error
close all; clear all; 

%filePath='C:\Users\Ingie\Documents\imager_data\xx0';
filePath='C:\Users\Ingie\Documents\imager_data\xx0\u003_001';
cd(filePath);

fileNames=dir('*.mat');
numFile=length(fileNames);

%Simulate data for processing
for i=1:numFile
   load(fileNames(i).name);
   
   keyboard
end
%Extract information from Analyzer file of interest

fileName= 'xx0_u011_002.analyzer.mat';
load(fileName); %load(fileName, '-mat');
looperConditions = Analyzer.L.param{1};
NoOrientations=length(Analyzer.loops.conds);
stimRep=Analyzer.L.reps;

trialNums ={}; % Extracts trial num for each condition
for i=1:NoOrientations
    for j=1:stimRep
       trialNums{i,j}= Analyzer.loops.conds{i}.repeats{1, j}.trialno
    end
end 


%Some script for renaming files
ISIdir=dir ('*.analyzer');
%rename Analyzer files that match condition and rename to a .mat
numFile=length(ISIdir);
for i = 1:numFile
    movefile(ISIdir(i).name, [ISIdir(i).name '.mat'])
end
