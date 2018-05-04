function screenconfig

global screenPTR screenNum Mstate

%screens=Screen('Screens');
%screenNum=max(screens);

screenNum=2; % GMH changed this to position stimulation on left screen (12/19/17)

screenRes = Screen('Resolution',screenNum);

screenPTR = Screen('OpenWindow',screenNum);

Screen(screenPTR,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

updateMonitor

Screen('PixelSizes',screenPTR)

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

Mstate.refresh_rate = 1/Screen('GetFlipInterval', screenPTR);

SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]'; %bottom left hand corner
%SyncLoc = [0 0 syncWX-1 syncWY-1]'; %top lefthand corner
SyncPiece = [0 0 syncWX-1 syncWY-1]';

%Set the screen

Screen(screenPTR, 'FillRect', 128) % 128
Screen(screenPTR, 'Flip');

wsync = Screen(screenPTR, 'MakeTexture', 0*ones(syncWY,syncWX)); % "low"

Screen('DrawTexture', screenPTR, wsync,SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');


