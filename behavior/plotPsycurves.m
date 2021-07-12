dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));

load('./weibull.mat');
load('./model_para.mat');
plotPsycurve(subject1, paraSub1, weibullFit1);

%% Helper function
function plotPsycurve(subData, modelPara, weibullPara)

cRef  = 0.075;
cTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.8];
plotPsycurveCrst(subData, modelPara, weibullPara, cRef, cTest)

cRef = 0.5;
cTest = [0.05, 0.1, 0.2, 0.4, 0.5, 0.8];
plotPsycurveCrst(subData, modelPara, weibullPara, cRef, cTest)

end

function plotPsycurveCrst(subData, modelPara, weibullPara, cRef, cTest)

refCrst    = [0.075, 0.5];
testCrst   = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
refV       = [0.5, 1, 2, 4, 8, 12];

supports = [0.1, 1.5; 0.25, 4; 0.25, 5; 0.25, 10; 0.25, 20; 0.25, 25];

c0 = modelPara(1); c1 = modelPara(2); c2 = modelPara(3);
noiseLevel = modelPara(4:end);

% Computing Prior Probability
domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

index = reshape(1 : 36, 6, 6)';
figure();

for i = 1 : length(cTest)
    for j = 1 : length(refV)
        crst1 = cRef; v1 = refV(j); crst2 = cTest(i);
        noise1 = noiseLevel(testCrst == crst1);
        noise2 = noiseLevel(testCrst == crst2);
        
        rangeV = supports(refV == v1, :);
        v2 = rangeV(1) : 0.05 : rangeV(2);
        
        testData = subData([3, 9], ...
            subData(2, :) == crst1 & subData(1, :) == v1 & subData(4, :) == crst2);
        [testSpeed, ~, idxC] = uniquetol(testData(1, :), 1e-4);
        resProb = zeros(1, length(testSpeed));
        dataCount = zeros(1, length(testSpeed));
        scale = 10;
        for idx = 1:length(testSpeed)
            resProb(idx) = mean(testData(2, idxC' == idx));
            dataCount(idx) = sum(idxC' == idx);
        end
        
        subplot(6, 6, index((i-1) * 6 + j));
        if(sum(dataCount) > 0)
            para = weibullPara(refCrst == crst1, refV == v1, testCrst == crst2, :);
            pLgrWeibull = wblcdf(v2, para(1), para(2));
            pLgrBayes = zeros(1, length(v2));
                                    
            [estsRef, probRef] = mappingEstimator(prior, noise1, v1);
            for k = 1 : length(pLgrBayes)
                [estsTest, probTest] = mappingEstimator(prior, noise2, v2(k));
                pLgrBayes(k) = probFasterGrid(estsRef, probRef, estsTest, probTest);
            end
            
            plot(v2, pLgrWeibull, 'r', 'LineWidth', 1.5); hold on;
            plot(v2, pLgrBayes,   'b', 'LineWidth', 1.5);
        end
        
        scatter(testSpeed, resProb, dataCount * scale, 'k');
        xlim([rangeV(1) rangeV(2)]); ylim([0, 1]);
        
        grid off; box off;
        if(i == 1)
            ylabel(sprintf('Reference Speed:\n%.1f', v1));
        end
        if(j == 1)
            title(sprintf('Test Contrast:\n%g', crst2), 'FontWeight', 'Normal');
        end
        if(j == 6)
            xlabel('Test Speed [deg/sec]');
        end
        
    end
end

end

