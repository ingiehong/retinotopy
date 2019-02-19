% Script to launch Slave-side visual stimulus for visual cortex imaging  
% 
% Ingie Hong, Johns Hopkins Medical Institute, 2018

% Before running this, ensure that Psychtoolbox is installed, no other 
% high-load applications are run on this slave computer, and a photodiode
% is correctly in place to detect stimulus onset from the bottom left
% corner of the visual stimulus screen.

%% Set up the PATH and display settings

addpath(genpath([fileparts(which('ISI_Slave')) filesep 'Stimulator_slave']));
configureDisplay;
%Screen('Preference', 'SkipSyncTests', 1)
