function runOnlineAnalysis(c, r, syncInfo)
%RUNONLINEANALYSIS  Run the online analysis once both the sync data and the frames are in.
%   The DAQ session's DataAvailable callback can fire while GrabSave is still collecting frames
%   (the analog record is total_time + 1 s, the camera starts later than the DAQ). The frames are
%   then not in Tens yet, so the analysis is parked and runPendingAnalysis (called by sendtoImager
%   right after GrabSave) runs it.
global Tens pendingAnalysis
if isempty(Tens) || ndims(Tens) < 3
    pendingAnalysis = {c, r, syncInfo};
    disp('Frames not in yet: the online analysis runs as soon as the acquisition finishes')
else
    pendingAnalysis = [];
    onlineAnalysis(c, r, syncInfo)
end
