function runPendingAnalysis
%RUNPENDINGANALYSIS  Run an online analysis that runOnlineAnalysis parked because the frames were
%   not in yet. Errors are reported as warnings so the acquisition loop goes on.
global pendingAnalysis Tens
if isempty(pendingAnalysis), return; end
a = pendingAnalysis; pendingAnalysis = [];
try
    onlineAnalysis(a{:})
catch e
    Tens = [];   % do not keep gigabytes of frames because the analysis failed
    warning('runPendingAnalysis:failed', 'online analysis failed: %s', e.message);
end
