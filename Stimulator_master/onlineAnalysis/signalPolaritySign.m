function s = signalPolaritySign(signalPolarity)
% Sign applied once to every frame before the Fourier (F1) phase analysis.
%   'negative' : intrinsic signal imaging, reflectance decreases on response -> -1
%                (this is what the old hard-coded 2^16-x inversion did; the constant cancels against F0)
%   'positive' : fluorescence imaging (GCaMP), signal increases on response -> +1
% Set Mstate.signalPolarity in configureMstate.m. It is saved with the analyzer (Analyzer.M)
% and next to f1m, so the analysis pipeline (generatekret) knows how the F1 maps were signed.
if nargin < 1 || isempty(signalPolarity)
    signalPolarity = 'negative';
end
switch lower(signalPolarity)
    case 'negative'
        s = -1;
    case 'positive'
        s = 1;
    otherwise
        error('signalPolaritySign:badValue', ...
            'signalPolarity must be ''negative'' (intrinsic) or ''positive'' (GCaMP), got ''%s''', signalPolarity);
end
