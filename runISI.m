%% Look in GettingStarted_SetupDisplay for calibrated parameters
%these lines set up the master instance of MATLAB
close all; clear all; 
cd('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\Stimulator_master');
addpath(genpath(pwd));
which configDisplayCom
configDisplayCom %run up to here
%white listing files from imager directory
%addpath('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\imager\sendtoImager.m');
%addpath('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\imager\checkforOverwrite.m');
addpath('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\Stimulator_master\TempCodeStimulator')

Stimulator
%% these lines set up the slave instance of MATLAB
%this runs slave in a separate session
%Make sure Psychtoolbox is running
cd('C:\Users\Ingie\Documents\My Code\GraceHwang\Slave\Stimulator_slave');
%IP address of Ingies' lab computer '10.194.195.180';
addpath(genpath(pwd));
configureDisplay;

%% these lines set up the imager from Master MATLAB instance
cd('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\imager');
imager
%addpath(genpath(pwd));
%rmpath('C:\Users\Ingie\Documents\My Code\GraceHwang\Master\imager\imager_mcr\');
%Warning: Function randperm has the same name as a MATLAB builtin. We suggest you rename the function to avoid a
%potential name conflict. 
%Warning: Function bandwidth has the same name as a MATLAB builtin. We suggest you rename the function to avoid a
%potential name conflict. 
%Warning: Function fopen has the same name as a MATLAB builtin. We suggest you rename the function to avoid a
%potential name conflict. 
%Warning: Function input has the same name as a MATLAB builtin. We suggest you rename the function to avoid a
%potential name conflict. 
%Warning: Function pause has the same name as a MATLAB builtin. We suggest you rename the function to avoid a
%potential name conflict. 

%%
which configCom
%edit configCom %change IP address to match current workstation
which configureMstate
% edit configureMstate.m
which configureDisplay
%edit configureDisplay
%cd('C:\Users\hwanggm1\Documents\code\Retinotopy\Slave\Stimulator_slave\configure\')
%cd('C:\Users\Ingie\Documents\My Code\Psychtoolbox');

% data will be saved to C:\Users\Ingie\Documents\imager_data