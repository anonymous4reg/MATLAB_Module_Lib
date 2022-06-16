% Concate 1~25kHz impedance scanning mat file in batch
% 
clear;clc

RootDir = 'D:\Travail\RE\HIL\[Routine] 阻抗专题\20210224_GW3.0D-PCS09_扫频\PLLvary\';
LowFreqDir = '1-250Hz\';
HighFreqDir = '250-2500Hz\';
OutDir = '1-2500Hz\';
common_file_name = 'DATA_ZP';
common_var_name = 'ZP';


PsetArray = 0:0.1:1;
QsetArray = -1:0.1:1;

PsetCell = num2cell(PsetArray);
QsetCell = num2cell(QsetArray);



for pset = 1:length(PsetCell)
    for qset = 1:length(QsetCell)
        
        case_name = strcat('P', num2str(PsetCell{pset}, '%.1f'), '-Q', num2str(QsetCell{qset}, '%.1f'));
        disp(strcat('Concate: ', case_name, '...'))
        try
            load(strcat(RootDir, LowFreqDir, case_name, '\', common_file_name));
            low_freq = eval(common_var_name);
            load(strcat(RootDir, HighFreqDir, case_name, '\', common_file_name));
            high_freq = eval(common_var_name);
            low_and_high = [low_freq; high_freq(2:end, :)];
            mkdir(strcat(RootDir, OutDir, case_name))
            save(strcat(RootDir, OutDir, case_name, '\', common_file_name, '.mat'), 'low_and_high')
            % Plot
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
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', common_file_name,'.emf'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', common_file_name,'.fig'))
            saveas(gca, strcat(RootDir, OutDir, case_name, '\', common_file_name,'.png'))
            close all
            
        catch ME
            disp('shit happened')
            rethrow(ME)
        end
        % break
    end
    % break
end
