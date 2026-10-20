function sz = frameSize(vid)
%FRAMESIZE  [width height] of the frames a videoinput object delivers.
%   The gentl adaptor keeps VideoResolution at the full (binned) sensor size even when a smaller
%   ROIPosition is set, so the ROI is the authoritative frame size; VideoResolution is the fallback.
roi = double(vid.ROIPosition);
if numel(roi) == 4 && all(roi(3:4) > 0)
    sz = roi(3:4);
else
    sz = double(vid.VideoResolution);
end
