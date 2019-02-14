% Script to launch all Master-side apps for visual cortex imaging (imager and Stimulator)
% 
% Ingie Hong, Johns Hopkins Medical Institute, 2018

% Please edit configCom %change IP address to match current workstation
% Acquired data will be saved to C:\Users\USERNAME\Documents\imager_data

%% Close all windows and clear all variables, including hidden globals
clear all
close all force % close all windows
clearvars -global % clear all variables, including hidden globals
imaqreset % To reset image acquisition toolbox, in case of a camera error

%% Set up the PATH and display settings
addpath(genpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master']));
%configDisplayCom 

%% these lines set up the imager from Master MATLAB instance
addpath([fileparts(which('ISI_Master')) filesep 'imager'])
imager

%% Stimulator
%addpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master' filesep 'TempCodeStimulator'])
Stimulator

%% Set window positions

global GUIhandles imagerhandles
movegui(GUIhandles.main.figure1, 'northwest')
movegui(GUIhandles.looper.figure1, 'northeast')
movegui(GUIhandles.param.figure1, 'north')
ScreenSize=get(0,'ScreenSize');
movegui(imagerhandles.figure1, [ScreenSize(3)-1280-20 45 ])
