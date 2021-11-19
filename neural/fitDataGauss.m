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
fano = fanoFactor(neurData.speed_values, neurData.response_values);

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
fano = zeros(nNeuron, 1);

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

    fano(idx) = fanoFactor(neurData.speed_values, neurData.response_values);
    
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
