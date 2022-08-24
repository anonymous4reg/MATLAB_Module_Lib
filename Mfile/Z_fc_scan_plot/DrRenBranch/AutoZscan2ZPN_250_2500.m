function [retZPD, retZND] = AutoZscan2ZPN(InputCmdCell)
    SrcFileDir  =   InputCmdCell{1};
    NameMatrix  =   InputCmdCell{2};
    Freq_begin  =   InputCmdCell{3};
    Freq_middle =   InputCmdCell{4};
    Freq_end    =   InputCmdCell{5};
    Freq_step   =   InputCmdCell{6};
    Step        =   InputCmdCell{7}; % Sample time of data(us)
    SaveTempsFlag = InputCmdCell{8};

% Step =50e-6; %仿真步长
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
% NameMatrix = {'U1.0-Q1.0','U1.0-Q0.75','U1.0-Q-0.75','U1.0-Q-1.0',...
%               'U1.0-Q0.5','U1.0-Q0.25','U1.0-Q-0.25','U1.0-Q-0.5',...
%               'U1.0-Q0.0'};
% NameMatrix = {'U1.0-Q1.0'};

OutSubDir = '250-2500Hz\';

for i=1:length(NameMatrix)
    filename = [NameMatrix{i}];
    OutRoot=strcat(SrcFileDir, '\', OutSubDir, '\', filename, '\');
    mkdir(OutRoot);
    Data = load(strcat(SrcFileDir, '\', filename,  '.mat'));

%     filename = [NameMatrix{i}];
%     Data = load([filename  '.mat']);
%     
%     OutRoot=[OutRoot_Dir,filename,'\'];
%     mkdir(OutRoot);
    [ZPD, ZND] = U_I_Z_F_10hz_250_2500(Step,Data,OutRoot, InputCmdCell);
    
    if SaveTempsFlag == true
            % save(strcat(OutRoot, 'DATA_ZPD_SISO.mat'), 'ZPD');
            % save(strcat(OutRoot, 'DATA_ZND_SISO.mat'), 'ZND');
            save(strcat(OutRoot, 'DATA_ZPD.mat'), 'ZPD');
            save(strcat(OutRoot, 'DATA_ZND.mat'), 'ZND');

            figure
            subplot(2,1,1);
            plot(ZPD(:,1),20*log10(ZPD(:,2)),'k');
            hold on;
            title('Positive sequence')
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            grid on
            set(gca, 'fontname', 'times new roman', 'fontsize', 14)
        
            subplot(2,1,2);
            plot(ZPD(:,1),ZPD(:,3),'k');
            hold on;
            xlabel('Frequency (Hz)');
            ylabel('Phase (deg)');
            grid on
            set(gca, 'fontname', 'times new roman', 'fontsize', 14)
            set(gcf, 'unit', 'centimeters', 'innerposition', [5, 5, 5+28, 5+14])
            f_savefig(OutRoot, 'DATA_ZPD', {'fig', 'png'}, 300)
        
            
            figure
            subplot(2,1,1);
            plot(ZND(:,1),20*log10(ZND(:,2)),'k');
            hold on;
            title('Negative sequence')
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            grid on
            set(gca, 'fontname', 'times new roman', 'fontsize', 14)
        
            subplot(2,1,2);
            plot(ZND(:,1),ZND(:,3),'k');
            hold on;
            xlabel('Frequency (Hz)');
            ylabel('Phase (deg)');
            grid on
            set(gca, 'fontname', 'times new roman', 'fontsize', 14)
            set(gcf, 'unit', 'centimeters', 'innerposition', [5, 5, 5+28, 5+14])
            f_savefig(OutRoot, 'DATA_ZND', {'fig', 'png'}, 300)
    end
    retZPD = ZPD;
    retZND = ZND;

    close all
end
