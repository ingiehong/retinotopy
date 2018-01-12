%This scripts load analyzer file and extracts grating information
%
% Grace Hwang
dbstop if error
close all; clear all; 

filePath='C:\Users\Ingie\Documents\imager_data\xx0';
cd(filePath);
ISIdir=dir ('*.analyzer');
%rename Analyzer files that match condition and rename to a .mat
numFile=length(ISIdir);
for i = 1:numFile
    movefile(ISIdir(i).name, [ISIdir(i).name '.mat'])
end

%I just noticed I created *.mat files when I was debugging u010_002 thru
%_006
%Extract information from file of interest

fileName= 'xx0_u011_002.analyzer.mat';
load(fileName);
looperConditions = Analyzer.L.param{1};
NoOrientations=length(Analyzer.loops.conds);
stimRep=Analyzer.L.reps;

trialNums ={}; % Extracts trial num for each condition
for i=1:NoOrientations
    for j=1:stimRep
       trialNums{i,j}= Analyzer.loops.conds{i}.repeats{1, j}.trialno
    end
end 


