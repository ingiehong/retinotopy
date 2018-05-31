%% Look in GettingStarted_SetupDisplay for calibrated parameters
%these lines set up the master instance of MATLAB
%automatically look for ip address in matlab with JAVA code
%h = java.net.InetAddress.getLocalHost();
%ipAddress = char(h.getHostAddress().toString());
close all; clear all; 
%cd('[fileparts(which('ISI_Master')) filesep 'Stimulator_master']);
addpath(genpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master']));
%which configDisplayCom
configDisplayCom %run up to here
%%
%white listing files from imager directory
%addpath('C:\Users\Ingie\Documents\My Code\Callaway_ISI\imager\sendtoImager.m');
%addpath('C:\Users\Ingie\Documents\My Code\Callaway_ISI\imager\checkforOverwrite.m');
addpath([fileparts(which('ISI_Master')) filesep 'Stimulator_master' filesep 'TempCodeStimulator'])

Stimulator
% %% these lines set up the slave instance of MATLAB
% %this runs slave in a separate session
% %Make sure Psychtoolbox is running
% cd('C:\Users\Ingie\Documents\My Code\Callaway_ISI\Stimulator_slave');
% %IP address of Ingies' lab computer '10.19104.195.180';
% addpath(genpath(pwd));
% configureDisplay;
% %Screen('Preference', 'SkipSyncTests', 1)
%% these lines set up the imager from Master MATLAB instance
%cd('C:\Users\Huganir lab\Documents\MATLAB\Callaway_ISI\imager');
addpath([fileparts(which('ISI_Master')) filesep 'imager'])
imager
%addpath(genpath(pwd));
%rmpath('C:\Users\Ingie\Documents\My Code\Callaway_ISI\imager\imager_mcr\');
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
% which configCom
% %edit configCom %change IP address to match current workstation
% which configureMstate
% % edit configureMstate.m
% which configureDisplay
% %edit configureDisplay
% %cd('C:\Users\hwanggm1\Documents\code\Retinotopy\Slave\Stimulator_slave\configure\')
% %cd('C:\Users\Ingie\Documents\My Code\Psychtoolbox');
% 
% % data will be saved to C:\Users\Ingie\Documents\imager_data