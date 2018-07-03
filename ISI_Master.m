%% Close all windows and clear all variables, including hidden globals
close all force % close all windows
clearvars -global % clear all variables, including hidden globals
imaqreset % To reset image acquisition toolbox, in case of camera error

%% Set up the master instance of MATLAB
addpath(genpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master']));
configDisplayCom 

%% these lines set up the imager from Master MATLAB instance
addpath([fileparts(which('ISI_Master')) filesep 'imager'])
imager

%% Stimulator
addpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master' filesep 'TempCodeStimulator'])
Stimulator

%% Set window positions

global GUIhandles imagerhandles
movegui(GUIhandles.main.figure1, 'northwest')
movegui(GUIhandles.looper.figure1, 'northeast')
movegui(GUIhandles.param.figure1, 'north')
movegui(imagerhandles.figure1, [500 45])

% %edit configCom %change IP address to match current workstation
% % data will be saved to C:\Users\Ingie\Documents\imager_data