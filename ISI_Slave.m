%% these lines set up the slave instance of MATLAB
%this runs slave in a separate session
%Make sure Psychtoolbox is running
cd('C:\Users\Ingie\Documents\My Code\Callaway_ISI\Stimulator_slave');
%IP address of Ingies' lab computer '10.194.195.180';
addpath(genpath(pwd));
configureDisplay;
%Screen('Preference', 'SkipSyncTests', 1)
