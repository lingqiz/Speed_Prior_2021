%% Fisher information
nNeuron = 470;
load('./fitPara.mat');

%% Poission model
xRange = 0.5 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

for idx = 1 : nNeuron
    para = fitPara(idx, :);
    tuning = @(stim) tuningGauss(para(1), para(2), para(3), ...
        para(4), para(5), stim);

    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);

    totalFisher = totalFisher + fisher .^ 2;
end

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(1); hold on;
plot(log(xRange), log(normFisher), 'LineWidth', 2, 'Color', 'red');

%% Add in Estimate of the Fano Factor
xRange = 0.5 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

for idx = 1 : nNeuron
    para = fitPara(idx, :);
    tuning = @(stim) tuningGauss(para(1), para(2), para(3), ...
        para(4), para(5), stim);

    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fano(idx) * fx);

    totalFisher = totalFisher + fisher .^ 2;
end

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(1); hold on;
plot(log(xRange), log(normFisher), 'LineWidth', 2, 'Color', 'yellow');

%% Simple Gaussian (Linear fisher, sum of derivatives)
xRange = 0.5 : 0.01 : 40;
deriMtx = zeros(nNeuron, length(xRange));

for idx = 1 : nNeuron
    para = fitPara(idx, :);
    tuning = @(stim) tuningGauss(para(1), para(2), para(3), ...
        para(4), para(5), stim);

    % linear Fisher information
    [fx, dfdx] = tuning(xRange);
    deriMtx(idx, :) = dfdx;
end

totalFisher = diag(deriMtx' * deriMtx);

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(1); hold on;
plot(log(xRange), log(normFisher), 'LineWidth', 2, 'Color', 'black');

%% Figure format
labelPos = [0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0];
xticks(log(labelPos));
xticklabels(arrayfun(@num2str, labelPos, 'UniformOutput', false));

probPos = [0.0025, 0.005, 0.01, 0.02, 0.04, 0.08, 0.16];
yticks(log(probPos));
yticklabels(arrayfun(@num2str, probPos, 'UniformOutput', false));

xlim(log([0.5, 40]))
ylim(log([0.0025, 0.20]));
set(gca, 'TickDir', 'out')
