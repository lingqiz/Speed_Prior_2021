%% Fisher information
nNeuron = 470;
load('./fitPara.mat');

%% Simple Gaussian (Linear fisher, sum of derivatives)
normalize = true;

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

if normalize
    normcst = trapz(xRange, sqrt(totalFisher)) * 2;
    normFisher = sqrt(totalFisher) / normcst;
else
    normFisher = sqrt(totalFisher);
end

% Fisher information
figure(1); hold on;
plot(log(xRange), log(normFisher), 'LineWidth', 2, 'Color', 'black');

%% Noise correlation
logPref = log(fitPara(:, 5) + 0.1);

for L = [0.5, 1.0, 2.0]
    corrMtx = zeros(nNeuron, nNeuron);

    for i = 1:nNeuron
        for j = 1:nNeuron
            if i == j
                corrMtx(i, j) = 1.0;
            else
                prefDist = abs(logPref(i) - logPref(j)) + 1e-3;
                corrMtx(i, j) = exp(-prefDist / L);
            end
        end
    end

    % check the cond number of corr matrix
    disp(cond(corrMtx));

    % Eigen Decomposition
    % M = VDV', M_inv = V' D_inv V

    [V, D] = eig(corrMtx);
    [D, idx] = sort(diag(D), 'descend');

    V = V(:, idx);

    % a low-rank approximation that captures 99.7% variance
    cumEigval = sort(unique(cumsum(D / sum(D))));
    cutOff = floor(interp1(cumEigval, 1:length(cumEigval), 0.997));    

    % only inverting the submatrix
    corrInv = V(1:cutOff, :)' * diag(1 ./ D(1:cutOff)) * V(1:cutOff, :);    

    %% Fisher information
    totalFisher = diag(deriMtx' * corrInv * deriMtx);

    if normalize
        normcst = trapz(xRange, sqrt(totalFisher)) * 2;
        normFisher = sqrt(totalFisher) / normcst;
    else
        normFisher = sqrt(totalFisher);
    end

    % Fisher information
    figure(1); hold on;
    plot(log(xRange), log(normFisher), 'LineWidth', 2);

    %% Corr hist
    figure();
    indexMtx = triu(~eye(nNeuron));
    corrMtx = corrMtx(indexMtx);

    hst = histogram(corrMtx(:), 'Normalization', 'probability', 'BinEdges', 0:0.05:1);
    hst.FaceColor = [0.25, 0.25, 0.25];
    hst.EdgeColor = [1.0, 1.0, 1.0];

    xlim([0, 1.0]);
    xticks(0 : 0.2 : 1);
    set(gca, 'TickDir', 'out'); box off;

    axisObj = gca;
    axisObj.LineWidth = 0.2;
end

%% Figure format
if normalize
    figure(1);

    labelPos = [0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0];
    xticks(log(labelPos));
    xticklabels(arrayfun(@num2str, labelPos, 'UniformOutput', false));

    probPos = [0.0025, 0.005, 0.01, 0.02, 0.04, 0.08, 0.16];
    yticks(log(probPos));
    yticklabels(arrayfun(@num2str, probPos, 'UniformOutput', false));

    xlim(log([0.5, 40]))
    ylim(log([0.0025, 0.20]));
    set(gca, 'TickDir', 'out')
end
