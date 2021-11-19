function fano = fanoFactor(speed, response)

speedVal = unique(speed);

responseAvg = zeros(size(speedVal));
responseVar = zeros(size(speedVal));

valid = [];
for vid = 1:length(speedVal)
    trialIdx = (speed == speedVal(vid));

    if sum(trialIdx) > 1
        responseAvg(vid) = mean(response(trialIdx));
        responseVar(vid) = var(response(trialIdx));

        valid = [valid, vid];
    else
        responseAvg(vid) = NaN;
        responseVar(vid) = NaN;
    end
end

responseAvg = speedVal(valid);
responseVar = responseVar(valid);

mdl = fitlm(responseAvg, responseVar, 'Intercept', false);
fano = mdl.Coefficients{1, 1};

end

