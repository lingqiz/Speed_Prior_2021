%% Fisher information
nNeuron = 470;
load('./fitPara.mat');
showPlot = false;

xRange = 0.5 : 0.01 : 40;
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

normcst = trapz(xRange, sqrt(totalFisher)) * 2;
normFisher = sqrt(totalFisher) / normcst;

% Fisher information
figure(); subplot(1, 2, 1);
plot(xRange, totalFisher, '-k', 'LineWidth', 2);

subplot(1, 2, 2);
plot(log(xRange), log(normFisher), '-k', 'LineWidth', 2);

fitlm(log(xRange'), log(normFisher'))

%% Fisher information demo
xRange = 0.5 : 0.01 : 40;

figure(); hold on; yyaxis left
for idx = 1 : 20
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
        
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

figure(); hold on; yyaxis left
for idx = 1 : 20
    parameter = fitPara(idx, :);
    tuning = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);
    
    % Fisher information
    [fx, dfdx] = tuning(xRange);
    fisher = abs(dfdx) ./ sqrt(fx);
        
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
set(gca, 'TickDir', 'out');
set(gca, 'YScale', 'log');
set(gca, 'YMinorTick', 'off');

box off; grid off;
