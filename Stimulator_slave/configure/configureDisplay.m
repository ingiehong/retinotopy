function configureDisplay(varargin)
dbstop if error
close all

%clear all;

Priority(2);  %Make sure priority is set to "real-time"  GMH 2 is realtime

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

configurePstate('PG') %Use grater as the default when opening
configureMstate

configCom(varargin);

configSync;

%configShutter;  % GMH comment this out

screenconfig;

