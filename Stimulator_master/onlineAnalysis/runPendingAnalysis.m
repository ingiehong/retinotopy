function runPendingAnalysis
%RUNPENDINGANALYSIS  Run an online analysis that runOnlineAnalysis parked because the frames were
%   not in yet. Errors are reported as warnings so the acquisition loop goes on.
global pendingAnalysis
if isempty(pendingAnalysis), return; end
a = pendingAnalysis; pendingAnalysis = [];
try
    onlineAnalysis(a{:})
catch e
    warning('runPendingAnalysis:failed', 'online analysis failed: %s', e.message);
end
