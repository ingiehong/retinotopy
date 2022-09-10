function Flim = getframeidx(Tlim,varargin)

%%%Find frame limits from time limits


%if varargin has 2 elements, it assumes you have entered
%(condition,repeat).  If there is 1 element, it assumes you have entered
%the (timetag).

%Tlim is a 2 element vector in ms

global Analyzer

if length(varargin) ==  2  
    cond = varargin{1};
    rep = varargin{2};
elseif length(varargin) == 1
	ttag = varargin{1};
    [cond rep] = getcondrep(ttag);
end


dS = processSyncs(Analyzer.loops.conds{cond}.repeats{rep}.dSyncswave,10000);
%dS = Analyzer.loops.conds{cond}.repeats{rep}.dispSyncs;

aS = Analyzer.loops.conds{cond}.repeats{rep}.acqSyncs;

sttime = dS(2) + Tlim(1)/1000;
[dum id] = min(abs(aS-sttime));
Flim(1) = id(1);  %closest frame to requested start time

endtime = dS(2) + Tlim(2)/1000;
[dum id] = min(abs(aS-endtime));
Flim(2) = id(1);  %closest frame to requested end time

