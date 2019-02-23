function configureDisplay(varargin)
% Revision 1-Oct.-2018 G. Hwang & I. Hong
% configShutter is no longer needed

Priority(2);  %Make sure priority is set to "real-time"; 2=realtime

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

configurePstate('PG') %Use grater as the default when opening
configureMstate

configCom(varargin);

configSync;

%configShutter;  % obsolete

screenconfig;

