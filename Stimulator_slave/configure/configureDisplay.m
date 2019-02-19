function configureDisplay(varargin)

close all

%clear all;

Priority(2);  %Make sure priority is set to "real-time"  2 is realtime

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

configurePstate('PG') %Use grater as the default when opening
configureMstate

configCom(varargin);

configSync;

%configShutter;  % no shutter 

screenconfig;

