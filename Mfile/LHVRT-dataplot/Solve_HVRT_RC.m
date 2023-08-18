clear;clc
% 
%% User input zone
R1 = 0.945576909;  %系统阻抗的R
L = 0.213519609;  %系统阻抗的L


%% Don't touch the following code
syms C R2;
StepLevel = [1.3, 1.25, 1.2]';
Q = 1;

RresultCell = [];
CresultCell = [];

for step_idx = 1:3
    tmp_d = StepLevel(step_idx);
    w = 100*pi;
    eqns = [sqrt(R2^2 + (1/(w*C))^2) / sqrt( (R1+R2)^2 + (w*L - 1/(w*C))^2 ) == tmp_d,...
            1/R2*sqrt(L/C) == Q];
    vars = [C, R2];
    [solveC, solveR2] = solve(eqns, vars);
    
    tmpR = double(solveR2);
    tmpC = double(solveC);
    
    pos_R_idx = (tmpR > 0);
    tmpR = tmpR(pos_R_idx);
    tmpC = tmpC(pos_R_idx);
    
    [tmpR, tmpRidx] = max(tmpR);
    Rresult = tmpR;
    Cresult = tmpC(tmpRidx);
    
    RresultCell = [RresultCell; Rresult];
    CresultCell = [CresultCell; Cresult];
end

ResultTab = table(StepLevel, RresultCell, CresultCell, ...
    'VariableNames', ["Ustep (p.u)", "Rsc (ohm)", "Csc (Farad)"])

% disp('Calc Result')
% disp('R2')
% double(solveR2)
% disp('Capcitance')
% double(solveC)
