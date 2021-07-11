%% Load neurons
nNeuron = 470;

neuroFile = cell(nNeuron, 1);
files = dir('./DeAngelis/*.mat');

idx = 1;
for file = files'
    neuroFile{idx} = load(fullfile('./DeAngelis', file.name));
    idx = idx + 1;
end

%% Fit to a single neuron
idx = randi(nNeuron);
neurData = neuroFile{idx};

figure();
yyaxis left
scatter(neurData.speed_values, neurData.response_values, 200, 'k', 'LineWidth', 1);

nRand = 0;
[parameter, func] = fitGauss(neurData.speed_values, neurData.response_values, 'rmse', 'fminsearch', nRand);

axisLim = xlim;
xRange = 0.0 : 0.05 : 35;

hold on;
plot(xRange, func(xRange), '-k', 'LineWidth', 2);
set(gca, 'TickDir', 'out');

% Differentiation
xRange = 0.5 : 0.05 : 35;
[fx, dfdx] = func(xRange);
plot(xRange, dfdx, '--r', 'LineWidth', 2);

xticks(5 : 10 : 35);
xlim([-1, 35]);

% Fisher information
yyaxis right
fisher = abs(dfdx) ./ sqrt(fx);
plot(xRange, fisher .^ 2, '-r', 'LineWidth', 2);

%% Sample a few neuron and plot the tuning curves
nPlot = 20;
figure();
for count = 1:10
    idx = randi(nNeuron);
    neurData = neuroFile{idx};
    
    nRand = 0;
    [parameter, func] = fitGauss(neurData.speed_values, neurData.response_values, 'rmse', 'fminsearch', nRand);
    
    axisLim = xlim;
    xRange = 0.0 : 0.05 : 35;
    
    hold on;
    plot(xRange, func(xRange) / max(func(xRange)), 'LineWidth', 1.5, 'Color', ones(1,3) * 0.5);
    set(gca, 'TickDir', 'out');
end
ylim([-0.1, 1.2]);

%% Fit to the entire population of neurons
nNeuron = 470;
nParas  = 5;
showPlot = false;

fitRSquared = zeros(nNeuron, 1);
rSquaredAvg = zeros(nNeuron, 1);
fitPara = zeros(nNeuron, nParas);

files = dir('./DeAngelis/*.mat');
idx = 1;
for file = files'
    neurData = load(fullfile('./DeAngelis', file.name));
    
    if showPlot
        figure();
        scatter(neurData.speed_values, neurData.response_values, 'k');
    end
    
    nRand = 5;
    [parameter, func, rSquared] = fitGauss(neurData.speed_values, neurData.response_values, 'rmse', 'fminsearch', nRand);
    fitRSquared(idx) = rSquared;
    fitPara(idx, :) = parameter;
    
    speed = unique(neurData.speed_values);
    response = [];
    for vid = 1:length(speed)
        response = [response mean(neurData.response_values(neurData.speed_values == speed(vid)))];
    end
    
    sTotal = sum((response - mean(response)) .^ 2);
    sRes   = sum((response' - func(speed)) .^ 2);
    rSquaredAvg(idx) = 1 - sRes / sTotal;
    
    if showPlot
        axisLim = xlim;
        xRange = axisLim(1) : 0.05 : axisLim(2);
        hold on;
        plot(xRange, func(xRange), 'k', 'LineWidth', 1);
    end
    
    idx = idx + 1;
    
end

%% Goodness-of-fit/R-squared
figure(); subplot(1, 2, 1);
histogram(fitRSquared); hold on;
plot(median(fitRSquared) * ones(1, 2), ylim(), '--k', 'LineWidth', 2);
xlim([0, 1]); title(strcat('R squared:', num2str(median(fitRSquared))));

subplot(1, 2, 2);
histogram(rSquaredAvg); hold on;
plot(median(rSquaredAvg) * ones(1, 2), ylim(), '--k', 'LineWidth', 2);
xlim([0, 1]); title(strcat('R squared:', num2str(median(rSquaredAvg))));

%% Fisher information
showPlot = false;

xRange = 0.1 : 0.01 : 100;
totalFisher = zeros(1, length(xRange));

for idx = 1 : nNeuron
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
    
    totalFisher = totalFisher + fisher .^ 2;
    if showPlot
        figure(); subplot(1, 2, 1);
        plot(xRange, fx, '-k', 'LineWidth', 2); hold on;
        plot(xRange, dfdx, '--k', 'LineWidth', 2);
        xlim([0, 20]);
        
        subplot(1, 2, 2);
        plot(xRange, fisher, '-k', 'LineWidth', 2);
        xlim([0, 20]);
    end
end
totalFisher = sqrt(totalFisher);

normcst = trapz(xRange, totalFisher) * 2;
totalFisher = totalFisher / normcst;

% Fisher information
figure(); subplot(1, 2, 1);
plot(xRange, totalFisher, '-k', 'LineWidth', 2);

subplot(1, 2, 2);
plot(log(xRange), log(totalFisher), '-k', 'LineWidth', 2);

fitlm(log(xRange'), log(totalFisher'))

%% Fisher information demo
xRange = 0.8 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

figure(); hold on; yyaxis left
for idx = 1 : 20
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
    
    totalFisher = totalFisher + fisher .^ 2;
    plot(log(xRange), fisher .^ 2, '-r', 'LineWidth', 0.5);
    
end

yyaxis right
plot(log(xRange), totalFisher, '-k', 'LineWidth', 2);

xtickPos = [1, 2, 4, 8, 16, 32];
xticks(log(xtickPos));
xticklabels(xtickPos);
xlim([-0.22, 3.7]);
set(gca, 'TickDir', 'out');

%% Fisher information demo (log space)
xRange = 0.5 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

figure(); hold on; yyaxis left
for idx = 1 : 20
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
    
    totalFisher = totalFisher + fisher .^ 2;
    plot(log(xRange), fisher .^ 2, '-', 'LineWidth', 0.5, 'Color', ones(1,3) * 0.5);
    
end
ylim([1e-8, 5e2]);
yticks([1e-8, 1e-6, 1e-4, 1e-2, 1, 1e2]);
set(gca, 'YScale', 'log');
set(gca, 'YMinorTick', 'off');

yyaxis right
plot(log(xRange), totalFisher, '-r', 'LineWidth', 2);

xtickPos = [1, 2, 4, 8, 16, 32];
xticks(log(xtickPos));
xticklabels(xtickPos);
xlim([-0.22, 3.7]);
ylim([1e-8, 5e2]);
set(gca, 'TickDir', 'out');
set(gca, 'YScale', 'log');
set(gca, 'YMinorTick', 'off');

box off; grid off;
