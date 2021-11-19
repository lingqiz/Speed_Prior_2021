%% Fisher information
nNeuron = 470;
load('./fitPara.mat');

%% Poission model
xRange = 0.5 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

for idx = 1 : nNeuron
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
    
    totalFisher = totalFisher + fisher .^ 2;    
end

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(1); hold on;

plot(log(xRange), log(normFisher), 'LineWidth', 2);
fitlm(log(xRange'), log(normFisher'))

%% Add in Estimate of the Fano Factor
xRange = 0.5 : 0.01 : 40;
totalFisher = zeros(1, length(xRange));

for idx = 1 : nNeuron
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fano(idx) * fx);
    
    totalFisher = totalFisher + fisher .^ 2;    
end

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(1); hold on;

plot(log(xRange), log(normFisher), 'LineWidth', 2);
fitlm(log(xRange'), log(normFisher'))

%% Consider a correlation noise model
histogram(fitpara(:, 5));
