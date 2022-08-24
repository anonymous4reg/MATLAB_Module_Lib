function AutoZscan2ZPN(InputCmdCell)
clear
clc

Step =50e-6; %仿真步长
%% 将扫频数据命名为下面矩阵名称形式
%风机或者光伏
% NameMatrix = {'P1.0-Q1.0','P1.0-Q0.0','P1.0-Q-1.0',...
%               'P0.9-Q1.0','P0.9-Q0.0','P0.9-Q-1.0',...
%               'P0.8-Q1.0','P0.8-Q0.0','P0.8-Q-1.0',...
%               'P0.7-Q1.0','P0.7-Q0.0','P0.7-Q-1.0',...
%               'P0.6-Q1.0','P0.6-Q0.0','P0.6-Q-1.0',...
%               'P0.5-Q1.0','P0.5-Q0.0','P0.5-Q-1.0',...
%               'P0.4-Q1.0','P0.4-Q0.0','P0.4-Q-1.0',...
%               'P0.3-Q1.0','P0.3-Q0.0','P0.3-Q-1.0',...
%               'P0.2-Q1.0','P0.2-Q0.0','P0.2-Q-1.0',...
%               'P0.1-Q1.0','P0.1-Q0.0','P0.1-Q-1.0',...
%               'P0.0-Q1.0','P0.0-Q0.0','P0.0-Q-1.0',...
%               'U1.05','U0.95'}; 
% %SVG
% NameMatrix = {'U1.0-Q1.0' 'U1.0-Q0.2' 'U1.0-Q-0.2' 'U1.0-Q-1.0'...
%                'U1.05-Q1.0' 'U1.05-Q0.2' 'U1.05-Q-0.2' 'U1.05-Q-1.0'...
%               'U0.95-Q1.0' 'U0.95-Q0.2' 'U0.95-Q-0.2' 'U0.95-Q-1.0'};
NameMatrix = {'U1.0-Q1.0','U1.0-Q0.75','U1.0-Q-0.75','U1.0-Q-1.0',...
              'U1.0-Q0.5','U1.0-Q0.25','U1.0-Q-0.25','U1.0-Q-0.5',...
              'U1.0-Q0.0'};
% NameMatrix = {'U1.0-Q1.0'};

OutRoot_Dir = '250-2500Hz\';

for i=1:length(NameMatrix)

    filename = [NameMatrix{i}];
    Data = load([filename  '.mat']);
    
    OutRoot=[OutRoot_Dir,filename,'\'];
    mkdir(OutRoot);
    U_I_Z_F_10hz_250_2500(Step,Data,OutRoot);


end
