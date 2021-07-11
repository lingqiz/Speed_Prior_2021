function [resp, dFdStim] = tuningGauss(base, amp, sigma, offset, pref, stim)

qStim = (stim + offset) ./ (pref + offset);
resp  = base + amp * exp(- (log(qStim) .^ 2) ./ (2 * (sigma .^ 2)));

delta = 1e-4;
qStim = (stim + delta + offset) ./ (pref + offset);
dF = base + amp * exp(- (log(qStim) .^ 2) ./ (2 * (sigma .^ 2))) - resp;

dFdStim = dF ./ delta;

end

