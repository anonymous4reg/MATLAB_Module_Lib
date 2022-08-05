% This subroutine concate 1~250Hz and 250Hz~25kHz's DATA_ZPD file and save
% those data mat files and figures into a specific folder.

% 3 kinds of figure files will be saved.
% .fig: easy to manipulate without touching raw data
% .png: easy to quick check
% .emf: vector figure, can be pasted into Microsoft Word without lossing any
% resolution
clear;clc

RootDir = 'E:\HaiDe_DFIG_2MW_matfile\02-mat_file\Zscan\';
LowFreqDir = 'low\';
HighFreqDir = 'high\';
OutDir = '1-2500Hz\';  % This folder will be generated automatically.

% PsetCell = {'0.0', '0.75', '1.5', '2.25', '3.0'};
% QsetCell = {'0.0', '-0.4875', '-0.975', '0.4875', '0.975'};
% PsetCell = {'0.0', '1.05', '2.1', '3.15', '4.2'};
% QsetCell = {'0.0', '-1.0', '-2.0', '1.0', '2.0'};
% PsetCell = {'0.0', '0.75', '1.5', '2.25', '3.0'};
% QsetCell = {'0.0', '-0.75', '-1.5', '0.75', '1.5'};

PsetCell = {'P0.0', 'P0.5', 'P1.0', 'P1.5', 'P2.0'};
QsetCell = {'Q0.0', 'Q-0.2294', 'Q-0.4588', 'Q0.4588', 'Q0.2294'};

SubFolderCell = {};

for pset = 1:length(PsetCell)
    for qset = 1:length(QsetCell)
        case_name = strcat(PsetCell{pset}, '_', QsetCell{qset});
        idx_now = (pset-1)*length(QsetCell) + qset;
        idx_total = length(PsetCell) * length(QsetCell);
        fprintf('Concating [%i/%i]: %s ...\n', idx_now, idx_total, case_name)
        try
            load(strcat(RootDir, LowFreqDir, case_name, '\', 'DATA_ZPD'));
            low_freq = ZPD;
            load(strcat(RootDir, HighFreqDir, case_name, '\', 'DATA_ZPD'));
            high_freq = ZPD;
            low_and_high = [low_freq; high_freq];
            mkdir(strcat(RootDir, OutDir, case_name))
            save(strcat(RootDir, OutDir, case_name, '\', case_name, '_DATA_ZPD.mat'), 'low_and_high')
            save(strcat(RootDir, OutDir, case_name, '\', 'DATA_ZPD.mat'), 'low_and_high')
            % Plot 1
            figure
            subplot(2,1,1);
            plot(low_and_high(:,1),20*log(low_and_high(:,2)));
            xlabel('频率（Hz)');
            ylabel('幅值（dB)');
            grid on
            subplot(2,1,2);
            plot(low_and_high(:,1),low_and_high(:,3));
            xlabel('频率（Hz)');
            ylabel('相角（度)');
            grid on
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_ZukangScanBode.emf'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_ZukangScanBode.fig'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_ZukangScanBode.png'))
            close all
            % Plot 2
            figure
            subplot(2,1,1);
            semilogx(low_and_high(:,1),20*log10(low_and_high(:,2)));
            xlabel('频率（Hz)');
            ylabel('幅值（dB)');
            grid on
            subplot(2,1,2);
            semilogx(low_and_high(:,1),low_and_high(:,3));
            xlabel('频率（Hz)');
            ylabel('相角（度)');
            grid on
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_LogZukangScanBode.emf'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_LogZukangScanBode.fig'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', case_name, '_LogZukangScanBode.png'))
            close all
            
        catch ME
            disp('shit happened')
            rethrow(ME)
        end
%         break
    end
%     break
end
