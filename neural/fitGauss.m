function [parameter, func, rSquared] = fitGauss(speed, response, lossOption, optOption, nRand)
if ~exist('nRand', 'var')
    nRand = 0;
end

if strcmp(lossOption, 'poiss')
    poissLL = @(measure, lambda) measure .* log(lambda) - lambda;
    loss = @(para) - sum(poissLL(response, tuningGauss(para(1), para(2), para(3), para(4), para(5), speed)));
else
    loss = @(para) norm(sqrt(tuningGauss(para(1), para(2), para(3), para(4), para(5), speed)) - sqrt(response));
end

paraInit = [0, mean(response), 1, 0.01, 0];
paraLB = [0, 0, 0, 0, 0];
paraUB = [Inf, Inf, Inf, 10, 1e2];

if strcmp(optOption, 'fmincon')
    options = optimoptions('fmincon','Display','iter');
    [parameter, fval] = fmincon(loss, paraInit, [], [], [], [], paraLB, paraUB, [], options);
    
else
    opts = optimset('fminsearch');
    opts.Display = 'iter';
    opts.MaxIter = 1e4;
    opts.MaxFunEvals = 5e3;
    
    [parameter, fval] = fminsearchbnd(loss, paraInit, paraLB, paraUB, opts);
end

for idx = 1 : nRand
    if strcmp(optOption, 'fmincon')
        [parameterNew, fvalNew] = fmincon(loss, paraInit + rand(1, 5) * 10, [], [], [], [], paraLB, paraUB, [], options);
    else
        [parameterNew, fvalNew] = fminsearchbnd(loss, paraInit + rand(1, 5) * 10, paraLB, paraUB, opts);
    end
    
    if fvalNew < fval
        parameter = parameterNew;
        fval = fvalNew;
    end
end

func = @(stim) tuningGauss(parameter(1), parameter(2), parameter(3), parameter(4), parameter(5), stim);

sTotal = sum((sqrt(response) - mean(sqrt(response))) .^ 2);
sRes   = sum((sqrt(response) - sqrt(func(speed))) .^ 2);
rSquared = 1 - sRes / sTotal;

if ~isreal(rSquared)
    error('complex number');
end

end